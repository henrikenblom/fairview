package com.fairviewiq.spring.controllers;

import com.fairviewiq.utils.DBUtility;
import com.fairviewiq.utils.PersonListGenerator;
import com.google.gson.Gson;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 10/17/11
 * Time: 2:58 PM
 * To change this template use File | Settings | File Templates.
 */
public class DictionaryController {
    private Gson gson = new Gson();

    @Resource
    private GraphDatabaseService neo;

    private DBUtility dbUtility;

    @PostConstruct
    public void initialize() {
        dbUtility = DBUtility.getInstance(neo);
    }

    @RequestMapping(value = {"/fairview/ajax/dictionary/lookup_word.do"})
    public void getEmployeeData(HttpServletResponse response, HttpSession httpSession) {
        try {
            response.getWriter().print(gson.toJson("test"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
