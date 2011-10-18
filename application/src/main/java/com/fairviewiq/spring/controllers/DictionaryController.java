package com.fairviewiq.spring.controllers;

import com.fairviewiq.utils.DBUtility;
import com.google.gson.Gson;
import org.neo4j.graphdb.Direction;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import se.codemate.neo4j.SimpleRelationshipType;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.SortedMap;
import java.util.TreeMap;

/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 10/17/11
 * Time: 2:58 PM
 * To change this template use File | Settings | File Templates.
 */
@Controller
public class DictionaryController {
    private Gson gson = new Gson();

    @Resource
    private GraphDatabaseService neo;

    private DBUtility dbUtility;
    Node dictionaryNode;
    SortedMap<String, String> dictionary;

    @PostConstruct
    public void initialize() {
        dbUtility = DBUtility.getInstance(neo);
        dictionaryNode = getDictionaryNode();
        dictionary = new TreeMap<String, String>();
    }

    @RequestMapping(value = {"/fairview/ajax/dictionary/lookup_word.do"})
    public void lookupWord(HttpServletResponse response, HttpSession httpSession, @RequestParam("category") String category,
                           @RequestParam("value") String value) {
        if (dictionary.containsValue(value)) {
            try {
                response.getWriter().print(gson.toJson("value: " + value + "already exists and wasn't added to dictionary"));
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            dictionary.put(category, value);
            dictionaryNode.setProperty(category, dictionaryNode.getProperty(category) + "," + value);
            try {
                response.getWriter().print(gson.toJson("added value: " + value + " to category: " + category));
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @RequestMapping(value = {"/fairview/ajax/dictionary/get_dictionary.do"})
    public void getTags(HttpServletResponse response, HttpSession httpSession, @RequestParam("category") String category) {
        try {
            response.getWriter().print(gson.toJson(dictionaryNode.getProperty(category)));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private Node getDictionaryNode() {
        try {
            Node dictionary = neo.getReferenceNode().getSingleRelationship(new SimpleRelationshipType("HAS_DICTIONARY"), Direction.OUTGOING).getEndNode();
            return dictionary;
        } catch (Exception e) {
            return neo.getReferenceNode().createRelationshipTo(neo.createNode(), new SimpleRelationshipType("HAS_DICTIONARY")).getEndNode();
        }
    }
}
