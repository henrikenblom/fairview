package com.fairviewiq.spring.controllers;


import com.fairviewiq.utils.DBUtility;
import com.fairviewiq.utils.EmploymentListGenerator;
import com.fairviewiq.utils.FunctionListGenerator;
import com.fairviewiq.utils.PersonListGenerator;

import static com.fairviewiq.spring.controllers.FairviewAjaxController.*;

import com.google.gson.Gson;
import org.neo4j.graphdb.Direction;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.kernel.EmbeddedGraphDatabase;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import se.codemate.neo4j.SimpleRelationshipType;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.print.DocFlavor;
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
    private EmploymentListGenerator employmentListGenerator;
    private DBUtility dbUtility;

    @PostConstruct
    public void initialize() {

        functionListGenerator = new FunctionListGenerator((EmbeddedGraphDatabase) neo);
        personListGenerator = new PersonListGenerator((EmbeddedGraphDatabase) neo);
        employmentListGenerator = new EmploymentListGenerator((EmbeddedGraphDatabase) neo);
        dbUtility = DBUtility.getInstance(neo);

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
        addEmploymentValuesToRow(row, String.valueOf(functionNode.getId()), functionNode.getProperty("name", "").toString());
        row.put("description", functionNode.getProperty("description", "").toString());
        Node unitNode = dbUtility.getUnitOfEmployment(functionNode);
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

    @RequestMapping(value = {"/fairview/ajax/datatables/get_employment_data.do"})
    public void getEmploymentData(HttpServletResponse response, HttpSession httpSession){

        HashMap<String, ArrayList<HashMap<String, String>>> returnValue = new HashMap<String, ArrayList<HashMap<String, String>>>() ;
        ArrayList<HashMap<String, String>> aaData = new ArrayList<HashMap<String, String>>();

        for (Node employmentNode : employmentListGenerator.getSortList(PersonListGenerator.ALPHABETICAL, true)){
            HashMap<String, String> row = new HashMap<String, String>();
            loadEmploymentData(employmentNode, row);
            aaData.add(row);
        }

        returnValue.put("aaData", aaData);
        try{
            response.getWriter().print(gson.toJson(returnValue));
        } catch (IOException e){
            e.printStackTrace();
        }
    }

    private void loadEmployeeData(Node employeeNode, HashMap<String, String> row) {
        row.put("firstname", employeeNode.getProperty("firstname", "").toString());
        row.put("lastname", employeeNode.getProperty("lastname", "").toString());
        row.put("node_id", String.valueOf(employeeNode.getId()));

        Node employmentNode = getEmploymentNode(employeeNode);
        if (employmentNode != null) {
            addEmploymentValuesToRow(row, String.valueOf(employmentNode.getId()), employmentNode.getProperty("title", "").toString());
        } else {
            addEmploymentValuesToRow(row, "", "");
        }

        Node unitNode = dbUtility.getUnitOfEmployment(employmentNode);
        if (unitNode != null) {
            addUnitValuesToRow(row, String.valueOf(unitNode.getId()), unitNode.getProperty("name", "").toString());
        } else {
            addUnitValuesToRow(row, "", "");
        }
    }

    private void loadEmploymentData(Node  employmentNode, HashMap<String, String> row) {
        row.put("employment_title", employmentNode.getProperty("title", "").toString());
        row.put("employment_id", String.valueOf(employmentNode.getId()));

        Node employeeNode = getEmployeeNode(employmentNode);
        if ( employeeNode != null){
            addEmployeeValuesToRow(row, String.valueOf(employeeNode.getId()), employeeNode.getProperty("firstname", "").toString(), employeeNode.getProperty("lastname", "").toString());
        } else {
            addEmployeeValuesToRow(row, "", "", "");
        }

        Node unitNode = getUnitNode(employmentNode);
        if(unitNode != null){
            addUnitValuesToRow(row, String.valueOf(unitNode.getId()), unitNode.getProperty("unit_name", "").toString());
        } else {
            Node organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();
            addUnitValuesToRow(row, String.valueOf(organization.getId()), organization.getProperty("name", "").toString());
        }
    }

    private Node getUnitNode(Node employmentNode){
        Node retval = null;

        try{
            retval = employmentNode.getRelationships(new SimpleRelationshipType("BELONGS_TO")).iterator().next().getEndNode();
        } catch (Exception ex){
            //no-op
        }
        return retval;
    }

    private Node getEmployeeNode(Node employmentNode){
        Node retval = null;

        try{
            retval = employmentNode.getRelationships(new SimpleRelationshipType("HAS_EMPLOYMENT")).iterator().next().getStartNode();
        } catch (Exception ex){
            //no-op
        }
        return retval;
    }

    private Node getEmploymentNode(Node employeeNode) {

        Node retval = null;

        try {

            retval = employeeNode.getRelationships(new SimpleRelationshipType("HAS_EMPLOYMENT")).iterator().next().getEndNode();

        } catch (Exception ex) {
            // no-op
        }

        return retval;

    }

    private void addEmployeeValuesToRow(HashMap<String, String> row, String employeeNode, String firstName, String lastName){
        row.put("employee_id", employeeNode);
        row.put("firstname", firstName);
        row.put("lastname", lastName);
    }

    private void addUnitValuesToRow(HashMap<String, String> row, String unitId, String unitName) {
        row.put("unit_id", unitId);
        row.put("unit_name", unitName);
    }

    private void addEmploymentValuesToRow(HashMap<String, String> row, String employmentId, String employmentTitle) {
        row.put("employment_id", employmentId);
        row.put("employment_title", employmentTitle);
    }

}
