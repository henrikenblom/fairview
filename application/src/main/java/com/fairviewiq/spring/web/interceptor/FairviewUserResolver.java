package com.fairviewiq.spring.web.interceptor;

import org.apache.lucene.index.Term;
import org.apache.lucene.search.TermQuery;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;
import se.codemate.neo4j.NeoSearch;
import se.codemate.neo4j.NeoUtils;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class FairviewUserResolver extends HandlerInterceptorAdapter {

    @Resource
    private GraphDatabaseService neo;

    @Resource
    private NeoSearch neoSearch;

    private NeoUtils neoUtils;

    @PostConstruct
    private void init() {
        neoUtils = new NeoUtils(neo);
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if (request.getUserPrincipal() != null) {
            User user = (User) ((UsernamePasswordAuthenticationToken) request.getUserPrincipal()).getPrincipal();
            try {
                List<Node> nodes = neoSearch.getNodes(new TermQuery(new Term("email", user.getUsername())));
                if (nodes.size() == 1) {
                    request.setAttribute("self_node", nodes.get(0));
                }
            } catch (IOException e) {
            }
        }
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
    }

}
