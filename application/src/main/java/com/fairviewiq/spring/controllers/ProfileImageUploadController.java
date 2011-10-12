package com.fairviewiq.spring.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import sun.font.GraphicComponent;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Created by IntelliJ IDEA.
 * User: henrik
 * Date: 2011-10-11
 * Time: 13:51
 * To change this template use File | Settings | File Templates.
 */

@Controller
public class ProfileImageUploadController {

    private static final int MAX_HEIGHT = 100;
    private static final int MAX_WIDTH = 100;

    @RequestMapping(value = {"/fairview/ajax/submit_profileimage.do"})
    public void submitFile(HttpServletRequest request, HttpServletResponse response, @RequestParam("file") MultipartFile f) {

        try {
            InputStream in = new ByteArrayInputStream(f.getBytes());
            BufferedImage originalImage = ImageIO.read(in);
            BufferedImage newImage = new BufferedImage(MAX_HEIGHT,MAX_WIDTH, BufferedImage.TYPE_INT_RGB);
            paintComponent(newImage.getGraphics(), originalImage, getRatio(originalImage));

            /*For testing purposes
            File outputfile = new File("testing.png");
            ImageIO.write(newImage, "png", outputfile);*/

            response.setContentType("image/png");
            ImageIO.write(newImage, "png", response.getOutputStream());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void paintComponent(Graphics g, BufferedImage originalImage, double scaleFactor) {
        Graphics2D g2 = (Graphics2D) g;
        int newW = (int) (originalImage.getWidth() * scaleFactor);
        int newH = (int) (originalImage.getHeight() * scaleFactor);
        g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
                RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g2.drawImage(originalImage, 0, 0, newW, newH, null);
    }

    private double getRatio(BufferedImage image) {
        double ratio;
        if (image.getWidth() > image.getHeight())
            ratio = (double) MAX_WIDTH / image.getWidth();
        else
            ratio = (double) MAX_HEIGHT / image.getHeight();
        return ratio;
    }
}