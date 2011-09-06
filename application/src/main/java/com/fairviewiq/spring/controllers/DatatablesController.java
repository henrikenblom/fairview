package com.fairviewiq.spring.controllers;


import com.fairviewiq.utils.FunctionListGenerator;
import com.fairviewiq.utils.PersonListGenerator;

import static com.fairviewiq.spring.controllers.FairviewAjaxController.*;

import com.google.gson.Gson;
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
    private PersonListGenerator personListGenerator;

    @PostConstruct
    public void initialize() {

        functionListGenerator = new FunctionListGenerator((EmbeddedGraphDatabase) neo);
        personListGenerator = new PersonListGenerator((EmbeddedGraphDatabase) neo);

    }


    @RequestMapping(value = {"/fairview/ajax/datatables/get_function_data.do"})
    public void getFunctionData(HttpServletResponse response, HttpSession httpSession) {

        HashMap<String, ArrayList<HashMap<String, String>>> retval = new HashMap<String, ArrayList<HashMap<String, String>>>();
        ArrayList<HashMap<String, String>> aaData = new ArrayList<HashMap<String, String>>();

        for (Node functionNode : functionListGenerator.getSortedList(FunctionListGenerator.ALPHABETICAL, true)) {

            HashMap<String, String> row = new HashMap<String, String>();
            loadFunctionData(functionNode, row);
            aaData.add(row);
        }
        retval.put("aaData", aaData);

        try {
            response.getWriter().print(gson.toJson(retval));
        } catch (IOException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }


    }

    private void loadFunctionData(Node functionNode, HashMap<String, String> row) {
        addFunctionValuesToRow(row, String.valueOf(functionNode.getId()), functionNode.getProperty("name", "").toString());
        row.put("description", functionNode.getProperty("description", "").toString());
        Node unitNode = getUnitOfFunction(functionNode);
        if (unitNode != null) {
            addUnitValuesToRow(row, String.valueOf(unitNode.getId()), unitNode.getProperty("name").toString());
        } else {
            addUnitValuesToRow(row, "", "");
        }
    }

    @RequestMapping(value = {"/fairview/ajax/datatables/get_employee_data.do"})
    public void getEmployeeData(HttpServletResponse response, HttpSession httpSession) {

        HashMap<String, ArrayList<HashMap<String, String>>> returnValue = new HashMap<String, ArrayList<HashMap<String, String>>>();
        ArrayList<HashMap<String, String>> aaData = new ArrayList<HashMap<String, String>>();

        for (Node employeeNode : personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, true)) {
            HashMap<String, String> row = new HashMap<String, String>();
            loadEmployeeData(employeeNode, row);
            aaData.add(row);
        }

        returnValue.put("aaData", aaData);
        try {
            response.getWriter().print(gson.toJson(returnValue));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void loadEmployeeData(Node employeeNode, HashMap<String, String> row) {
        row.put("firstname", employeeNode.getProperty("firstname", "").toString());
        row.put("lastname", employeeNode.getProperty("lastname", "").toString());
        row.put("phone", employeeNode.getProperty("phone", "").toString());
        row.put("email", employeeNode.getProperty("email", "").toString());
        row.put("node_id", String.valueOf(employeeNode.getId()));

        Node functionNode = getFunctionOfEmployee(employeeNode);
        if (functionNode != null) {
            addFunctionValuesToRow(row, String.valueOf(functionNode.getId()), functionNode.getProperty("name").toString());
        } else {
            addFunctionValuesToRow(row, "", "");
        }

        Node unitNode = getUnitOfFunction(functionNode);
        if (unitNode != null) {
            addUnitValuesToRow(row, String.valueOf(unitNode.getId()), unitNode.getProperty("name").toString());
        } else {
            addUnitValuesToRow(row, "", "");
        }
    }

    private void addUnitValuesToRow(HashMap<String, String> row, String unitId, String unitName) {
        row.put("unit_id", unitId);
        row.put("unit_name", unitName);
    }

    private void addFunctionValuesToRow(HashMap<String, String> row, String functionId, String functionName) {
        row.put("function_id", functionId);
        row.put("function_name", functionName);
    }

}
