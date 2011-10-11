package com.fairviewiq.spring.controllers;

import com.fairviewiq.beans.FileUploadBean;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.SimpleFormController;

/**
 * Created by IntelliJ IDEA.
 * User: henrik
 * Date: 2011-10-11
 * Time: 13:51
 * To change this template use File | Settings | File Templates.
 */

public class ProfileImageUploadController extends SimpleFormController {

    @Override
    protected ModelAndView onSubmit(Object command) throws Exception {

        FileUploadBean fileUploadBean = (FileUploadBean) command;

        byte[] file = fileUploadBean.getFile();

        System.err.println("############# FILE LENGHT: " + file.length);

        return super.onSubmit(command);

    }
}
