package com.fairviewiq.spring.controllers;

import com.fairviewiq.beans.FileUploadBean;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindException;
import org.springframework.web.bind.annotation.RequestMapping;
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
    public void submitFile(HttpServletRequest request, HttpServletResponse response, Object command, BindException errors) throws Exception {

        FileUploadBean fileUploadBean = (FileUploadBean) command;

        byte[] file = fileUploadBean.getFile();

        System.err.println("############# FILE LENGHT: " + file.length);

    }
}
