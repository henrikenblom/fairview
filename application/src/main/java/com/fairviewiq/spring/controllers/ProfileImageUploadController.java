package com.fairviewiq.spring.controllers;

import com.fairviewiq.utils.DBUtility;
import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.io.xml.DomDriver;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;

/**
 * Created by IntelliJ IDEA.
 * User: henrik
 * Date: 2011-10-11
 * Time: 13:51
 * To change this template use File | Settings | File Templates.
 */

@Controller
public class ProfileImageUploadController {

    @Resource
    private GraphDatabaseService neo;

    private DBUtility dbUtility;

    private static final int SMALL_IMAGE_HEIGHT = 100;
    private static final int SMALL_IMAGE_WIDTH = 100;

    private static final int LARGE_IMAGE_HEIGHT = 500;
    private static final int LARGE_IMAGE_WIDTH = 500;

    private XStream xstream = new XStream(new DomDriver());

    @PostConstruct
    public void initialize() {
        dbUtility = DBUtility.getInstance(neo);
    }

    @RequestMapping(value = {"/fairview/ajax/submit_profileimage.do"})
    public void submitFile(HttpServletRequest request, HttpServletResponse response, @RequestParam("file") MultipartFile f,
                           @RequestParam("_nodeId") Long nodeId) {
        try {
            InputStream image = new ByteArrayInputStream(f.getBytes());
            BufferedImage originalImage = ImageIO.read(image);
            BufferedImage smallImage = scaleImage(originalImage, SMALL_IMAGE_WIDTH, SMALL_IMAGE_HEIGHT);
            BufferedImage largeImage = scaleImage(originalImage, LARGE_IMAGE_WIDTH, LARGE_IMAGE_HEIGHT);


            Relationship imageRelationship = dbUtility.createRelationship(nodeId, "HAS_IMAGE");
            Node imageNode = imageRelationship.getEndNode();
            imageNode.setProperty("small_image", xstream.toXML(smallImage));
            imageNode.setProperty("large_image", xstream.toXML(largeImage));
            imageNode.setProperty("filename", f.getName());
            imageNode.setProperty("type", f.getContentType());

            response.setContentType("text/plain");
            response.getOutputStream().print(String.valueOf(imageNode.getId()));
            response.getOutputStream().close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    @RequestMapping(value = {"/fairview/ajax/get_small_image.do"})
    public void getFile(HttpServletRequest request, HttpServletResponse response, @RequestParam("_nodeId") Long nodeId) {
        try {
            Node imageNode = dbUtility.getNode(nodeId);
            BufferedImage image = (BufferedImage) xstream.fromXML(imageNode.getProperty("small_image").toString());

            response.setContentType("image/png");
            ImageIO.write(image, "png", response.getOutputStream());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private BufferedImage scaleImage( BufferedImage originalImage, int width, int height) throws IOException {
        BufferedImage newImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        paintComponent(newImage.getGraphics(), originalImage, getRatio(originalImage, width, height));
        return newImage;
    }

    public void paintComponent(Graphics g, BufferedImage originalImage, double scaleFactor) {
        Graphics2D g2 = (Graphics2D) g;
        int newW = (int) (originalImage.getWidth() * scaleFactor);
        int newH = (int) (originalImage.getHeight() * scaleFactor);
        g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
                RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g2.drawImage(originalImage, 0, 0, newW, newH, null);
    }

    private double getRatio(BufferedImage image, int width, int height) {
        double ratio;
        if (image.getWidth() > image.getHeight())
            ratio = (double) width / image.getWidth();
        else
            ratio = (double) height / image.getHeight();
        return ratio;
    }
}