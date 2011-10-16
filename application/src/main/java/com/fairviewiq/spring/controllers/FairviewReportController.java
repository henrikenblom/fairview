package com.fairviewiq.spring.controllers;

import net.sf.jasperreports.engine.JasperCompileManager;
import org.apache.log4j.Logger;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import se.codemate.spring.controllers.JasperReportController;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;

import net.sf.jasperreports.engine.JRException;

public class FairviewReportController extends JasperReportController {

    private static Logger log = Logger.getLogger(FairviewReportController.class);

    @Override
    public void afterPropertiesSet() throws Exception {

        File[] reports = reportRoot.listFiles(new FilenameFilter() {
            public boolean accept(File dir, String name) {
                return name.endsWith(".jrxml");
            }
        });

        for (File sourceFile : reports) {
            File jasperFile = new File(sourceFile.getAbsolutePath().replace(".jrxml", ".jasper"));
            try {
                JasperCompileManager.compileReportToStream(new FileInputStream(sourceFile), new FileOutputStream(jasperFile));
                log.debug("Compiled "+jasperFile.getAbsolutePath());
            } catch (Exception e) {
                log.error("Compile failed for "+jasperFile.getAbsolutePath(),e);
                System.err.println(e);
            }
        }

        super.afterPropertiesSet();

    }

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws IOException, JRException {

        String uri = request.getRequestURI();

        if (uri.startsWith("/index.do")) {
            SecurityContext securityContext = SecurityContextHolder.getContext();
            Authentication authentication = securityContext.getAuthentication();
            ModelAndView modelAndView = generateReportModelAndView(request, "index.html");
            modelAndView.addObject("USERNAME", authentication.getName());
            for (GrantedAuthority authority : authentication.getAuthorities()) {
                modelAndView.addObject(authority.getAuthority(), "granted");
            }
            return modelAndView;
        } else {
            return super.handleRequest(request, response);
        }

    }

}
