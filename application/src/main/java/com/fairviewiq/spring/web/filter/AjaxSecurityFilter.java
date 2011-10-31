package com.fairviewiq.spring.web.filter;

import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.Principal;

public class AjaxSecurityFilter extends OncePerRequestFilter {

    protected void doFilterInternal(
            HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        Principal principal = request.getUserPrincipal();

        System.out.println(principal);

        filterChain.doFilter(request, response);

    }

}

