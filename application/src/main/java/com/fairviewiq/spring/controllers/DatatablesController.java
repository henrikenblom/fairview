package com.fairviewiq.spring.controllers;


import com.fairviewiq.utils.FunctionListGenerator;
import com.google.gson.Gson;
import com.sun.tools.corba.se.idl.toJavaPortable.StringGen;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.kernel.EmbeddedGraphDatabase;
import org.springframework.stereotype.Controller;
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
 * Date: 9/2/11
 * Time: 8:35 AM
 * To change this template use File | Settings | File Templates.
 */
@Controller
public class DatatablesController {

    private Gson gson = new Gson();

    @Resource
    private GraphDatabaseService neo;

    private FunctionListGenerator functionListGenerator;

    @PostConstruct
    public void initialize() {

        functionListGenerator = new FunctionListGenerator((EmbeddedGraphDatabase) neo);

    }


    @RequestMapping(value = {"/fairview/ajax/datatables/get_function_data.do"})
    public void getFunctionData(HttpServletResponse response, HttpSession httpSession) {

        HashMap<String, ArrayList<HashMap<String, String>>> retval = new HashMap<String, ArrayList<HashMap<String, String>>>();
        ArrayList<HashMap<String, String>> aaData = new ArrayList<HashMap<String, String>>();

        for (Node entry : functionListGenerator.getSortedList(FunctionListGenerator.ALPHABETICAL, true)) {

            HashMap<String, String> row = new HashMap<String, String>();

            row.put("name", entry.getProperty("name", "").toString());
            row.put("description", entry.getProperty("description", "").toString());

            aaData.add(row);

        }

        retval.put("aaData", aaData);

        try {
            response.getWriter().print(gson.toJson(retval));
        } catch (IOException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }


    }

}
