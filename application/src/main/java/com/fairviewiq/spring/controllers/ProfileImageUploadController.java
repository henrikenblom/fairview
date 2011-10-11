package com.fairviewiq.spring.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.validation.BindException;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.SimpleFormController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: henrik
 * Date: 2011-10-11
 * Time: 13:51
 * To change this template use File | Settings | File Templates.
 */

@Controller
public class ProfileImageUploadController {

    @RequestMapping(value = {"/fairview/ajax/submit_profileimage.do"})
    public ModelAndView submitFile(HttpServletRequest request, HttpServletResponse response, @RequestParam("qqfile") MultipartFile f) {

        if (f == null) {
            return new ModelAndView("upload", "msg", "The file is null.");
        }

        return new ModelAndView("upload", "msg", "File ( " + f.getOriginalFilename() + ") successfully uploaded.");

    }

}
