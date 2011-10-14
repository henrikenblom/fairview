package com.fairviewiq.spring.controllers;

import com.fairviewiq.utils.DBUtility;
import com.google.gson.Gson;
import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.io.xml.DomDriver;
import org.neo4j.graphdb.Direction;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import se.codemate.neo4j.SimpleRelationshipType;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.imageio.ImageIO;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.*;
import java.awt.geom.Rectangle2D;
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

    private static final int SMALL_IMAGE_HEIGHT = 120;
    private static final int SMALL_IMAGE_WIDTH = 80;

    private static final int LARGE_IMAGE_HEIGHT = 500;
    private static final int LARGE_IMAGE_WIDTH = 500;

    private XStream xstream = new XStream(new DomDriver());
    private Gson gson = new Gson();

    @PostConstruct
    public void initialize() {
        dbUtility = DBUtility.getInstance(neo);
    }

    @RequestMapping(value = {"/fairview/ajax/submit_profileimage.do"})
    public void submitFile(HttpServletRequest request, HttpServletResponse response, @RequestParam("file") MultipartFile f,
                           @RequestParam("_nodeId") Long nodeId) {
        try {
            Node imageNode = null;
            response.setContentType("application/json");
            try {
                InputStream image = new ByteArrayInputStream(f.getBytes());
                BufferedImage originalImage = ImageIO.read(image);
                BufferedImage smallImage = scaleImage(originalImage, SMALL_IMAGE_WIDTH, SMALL_IMAGE_HEIGHT);
                BufferedImage largeImage = scaleImage(originalImage, LARGE_IMAGE_WIDTH, LARGE_IMAGE_HEIGHT);

                Relationship imageRelationship = dbUtility.getOrCreateRelationship(nodeId, "HAS_IMAGE");
                imageNode = imageRelationship.getEndNode();

                ByteArrayOutputStream smallbos = new ByteArrayOutputStream();
                ImageIO.write(smallImage, "png", smallbos);
                ByteArrayOutputStream largebos = new ByteArrayOutputStream();
                ImageIO.write(largeImage, "png", largebos);

                imageNode.setProperty("small_image", smallbos.toByteArray());
                imageNode.setProperty("large_image", largebos.toByteArray());

                response.getOutputStream().print(gson.toJson("success"));
            } catch (Exception e) {
                response.getOutputStream().print(gson.toJson("error"));
            }
            response.getOutputStream().close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    @RequestMapping(value = {"/fairview/ajax/get_small_image.do"})
    public void getFile(HttpServletRequest request, HttpServletResponse response, @RequestParam("_nodeId") Long nodeId) throws IOException {
        try {
            Node employeeNode = dbUtility.getNode(nodeId);
            Node imageNode = employeeNode.getSingleRelationship(new SimpleRelationshipType("HAS_IMAGE"), Direction.OUTGOING).getEndNode();

            response.setContentType("image/png");
            byte[] imageData = (byte[]) imageNode.getProperty("small_image");
            response.getOutputStream().write(imageData);
            response.getOutputStream().flush();
        } catch (Exception ex) {
            response.getOutputStream().print(gson.toJson("error"));
        }
        response.getOutputStream().close();
    }

    @RequestMapping(value = {"/fairview/ajax/has_image.do"})
    public void hasImage(HttpServletRequest request, HttpServletResponse response, @RequestParam(value = "_nodeId", required = false) Long nodeId) throws IOException {
        response.setContentType("application/json");
        ServletOutputStream outputStream = response.getOutputStream();
        try {
            Node employeeNode = dbUtility.getNode(nodeId);
            Node imageNode = employeeNode.getSingleRelationship(new SimpleRelationshipType("HAS_IMAGE"), Direction.OUTGOING).getEndNode();
            outputStream.print(gson.toJson("true"));
        } catch (Exception ex) {
            outputStream.print(gson.toJson("false"));
        }
        response.getOutputStream().close();
    }

    private BufferedImage scaleImage(BufferedImage originalImage, int width, int height) throws IOException {
        BufferedImage newImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);

        paintComponent(newImage.getGraphics(), originalImage, getRatio(originalImage, width, height));
        return newImage;
    }

    public void paintComponent(Graphics g, BufferedImage originalImage, double scaleFactor) {
        Graphics2D g2 = (Graphics2D) g;
        int newW = (int) (originalImage.getWidth() * scaleFactor);
        int newH = (int) (originalImage.getHeight() * scaleFactor);
        g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
                RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g2.setColor(Color.WHITE);
        g2.fillRect(0, 0, SMALL_IMAGE_WIDTH, SMALL_IMAGE_HEIGHT);
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