package com.fairviewiq.spring.web.filter;

import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.security.Authentication;
import org.springframework.security.context.SecurityContextHolder;

import javax.servlet.ServletException;
import javax.servlet.FilterChain;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.Calendar;
import java.util.Date;
import java.io.IOException;
import java.security.Principal;

import com.fairviewiq.utils.UUIDGenerator;

public class AjaxSecurityFilter extends OncePerRequestFilter {

    protected void doFilterInternal(
            HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        Principal principal = request.getUserPrincipal();

        System.out.println(principal);

        filterChain.doFilter(request, response);

    }

}

