package com.fairviewiq.spring.security;

import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.util.AntPathMatcher;
import org.springframework.util.PathMatcher;
import org.springframework.web.filter.GenericFilterBean;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class AjaxQuirksFilter extends GenericFilterBean {

    private PathMatcher pathMatcher = new AntPathMatcher();

    private List<String> patterns = new ArrayList<String>();

    public void setUriPatterns(List<String> patterns) {
        for (String pattern : patterns) {
            if (pathMatcher.isPattern(pattern)) {
                this.patterns.add(pattern);
            } else {
                throw new IllegalArgumentException("'" + pattern + "' is not a valid ant path pattern.");
            }
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        try {
            chain.doFilter(request, response);
        } catch (AuthenticationCredentialsNotFoundException ex) {
            String uri = ((HttpServletRequest) request).getRequestURI();
            for (String path : patterns) {
                if (pathMatcher.match(path, uri)) {
                    response.setContentType("text/plain");
                    response.getWriter().write("{ \"exception\" : { \"type\" : \"login\", \"message\" : \"Login Required\", \"i18n_message\" : \"Login Required\" } }");
                    HttpSession session = ((HttpServletRequest) request).getSession(false);
                    if (session != null) {
                        session.removeAttribute("SPRING_SECURITY_SAVED_REQUEST_KEY");
                    }
                    return;
                }
            }
            throw ex;
        }
    }

}
