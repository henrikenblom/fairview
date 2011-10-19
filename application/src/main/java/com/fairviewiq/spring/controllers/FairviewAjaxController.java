package com.fairviewiq.spring.controllers;

import com.fairviewiq.utils.FunctionListGenerator;
import com.fairviewiq.utils.MultiSelectFunctionMember;
import com.fairviewiq.utils.PersonListGenerator;
import com.google.gson.Gson;
import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver;
import org.neo4j.graphdb.*;
import org.neo4j.kernel.EmbeddedGraphDatabase;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import se.codemate.neo4j.*;
import se.codemate.spring.controllers.NeoAjaxController;
import se.codemate.spring.mvc.ModelMapConverter;
import se.codemate.spring.mvc.XStreamView;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.lang.reflect.Array;
import java.util.*;

@Controller
public class FairviewAjaxController {

    private static String TYPE_NODE = "node";
    private static String TYPE_RELATIONSHIP = "relationship";

    @Resource
    private GraphDatabaseService neo;

    @Resource
    private NeoSearch neoSearch;

    private XStreamView xstreamView;
    private NeoUtils neoUtils;
    private FunctionListGenerator functionListGenerator;
    private Gson gson = new Gson();
    private Node organization = null;

    private HashMap<String, TreeSet<String>> dictionary = new HashMap<String, TreeSet<String>>();

    @PostConstruct
    public void initialize() {
        //Transaction executed in the initialize method to prevent it from being handled by a transaction handler higher up in the hierarchy
        Transaction transaction = neo.beginTx();
        try {
            getDictionaryNode();
            transaction.success();
        } catch (Exception e) {
            transaction.failure();
        } finally {
            transaction.finish();
        }

        neoUtils = new NeoUtils(neo);
        XStream xstream = new XStream(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);

        xstream.registerConverter(new ModelMapConverter(xstream.getMapper()), XStream.PRIORITY_VERY_HIGH);
        xstream.registerConverter(new XStreamNodeConverter(neo, xstream.getMapper()));
        xstream.registerConverter(new XStreamRelationshipConverter(neo, xstream.getMapper()));

        xstream.alias("model", ModelMap.class);
        xstream.alias("node", Node.class);
        xstream.alias("relationship", Relationship.class);

        try {
            xstream.alias("node", Class.forName("org.neo4j.kernel.impl.core.NodeProxy"));
        } catch (ClassNotFoundException e) {
            // no-op
        }

        try {
            xstream.alias("node", Class.forName("org.neo4j.impl.core.NodeImpl"));
        } catch (ClassNotFoundException e) {
            // no-op
        }

        try {

            xstream.alias("node", Class.forName("org.neo4j.impl.core.NodeProxy"));

        } catch (ClassNotFoundException e) {
            // no-op
        }
        try {
            xstream.alias("relationship", Class.forName("org.neo4j.kernel.impl.core.RelationshipProxy"));
        } catch (ClassNotFoundException e) {
            // no-op
        }
        try {
            xstream.alias("relationship", Class.forName("org.neo4j.impl.core.RelationshipImpl"));
        } catch (ClassNotFoundException e) {
            // no-op
        }
        try {
            xstream.alias("relationship", Class.forName("org.neo4j.impl.core.RelationshipProxy"));

        } catch (ClassNotFoundException e) {
            // no-op
        }
        try {
            xstream.alias("sortedset", SortedSet.class);
        } catch (Exception e) {
            //no-op
        }

        xstreamView = new XStreamView(xstream, "text/json");

        try {
            organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();
        } catch (Exception ex) {
            // no-op
        }
        functionListGenerator = new FunctionListGenerator((EmbeddedGraphDatabase) neo);

    }

    @RequestMapping(value = {"/fairview/ajax/delete_unit.do"})
    public ModelAndView deleteUnit(@RequestParam("_nodeId") Long nodeId) {

        ModelAndView mav = new ModelAndView(xstreamView);

        Node node = neo.getNodeById(nodeId);
        LinkedList<Node> childNodes = new LinkedList<Node>();

        Node parentNode = node.getRelationships(new SimpleRelationshipType("HAS_UNIT"), Direction.INCOMING).iterator().next().getStartNode();

        try {

            for (Relationship relationship : node.getRelationships(new SimpleRelationshipType("HAS_UNIT"), Direction.OUTGOING)) {

                childNodes.add(relationship.getEndNode());

            }

        } catch (Exception ex) {
            //no-op
        }

        for (Relationship relationship : node.getRelationships()) {

            relationship.delete();

        }

        if (childNodes.size() > 0) {

            for (Node childNode : childNodes) {

                Relationship relationship = parentNode.createRelationshipTo(childNode, new SimpleRelationshipType("HAS_UNIT"));
                mav.addObject(XStreamView.XSTREAM_ROOT, relationship);

            }

        }

        node.delete();

        return mav;
    }

    @RequestMapping(value = {"/fairview/ajax/get_units.do"})
    public ModelAndView getUnits() {

        ModelAndView mav = new ModelAndView(xstreamView);

        ArrayList<Node> retval = new ArrayList<Node>();

        retval.add(organization);

        populateUnitArrayList(retval, organization);

        mav.addObject(XStreamView.XSTREAM_ROOT, retval);

        return mav;

    }

    private void populateUnitArrayList(ArrayList<Node> arrayList, Node root) {

        for (Relationship relationship : root.getRelationships(new SimpleRelationshipType("HAS_UNIT"), Direction.OUTGOING)) {

            arrayList.add(relationship.getEndNode());

            populateUnitArrayList(arrayList, relationship.getEndNode());


        }


    }

    @RequestMapping(value = {"/fairview/ajax/get_assigned_tasks.do"})
    public ModelAndView getAssignedGoals(@RequestParam("_nodeId") Long nodeId) {

        Node node = neo.getNodeById(nodeId);

        ArrayList<Node> retval = new ArrayList<Node>();

        for (Relationship relationship : node.getRelationships(new SimpleRelationshipType("ASSIGNED_TO"), Direction.INCOMING)) {

            retval.add(relationship.getStartNode());

        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, retval);

        return mav;

    }

    public static Node getFunctionOfEmployee(Node employeeNode) {
        Node functionNode = null;
        try {
            Traverser employmentTraverser = employeeNode.traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.OUTGOING);
            Traverser functionTraverser = employmentTraverser.iterator().next().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("PERFORMS_FUNCTION"), Direction.OUTGOING);
            functionNode = functionTraverser.iterator().next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return functionNode;
    }

    @RequestMapping(value = {"/fairview/ajax/get_functions.do"})
    public ModelAndView getFunctions(@RequestParam("_nodeId") Long nodeId) {
        HashMap<Long, String> retval = new HashMap<Long, String>();

        Node node = neo.getNodeById(nodeId);
        Node functionNode = getFunctionOfEmployee(node);
        if (functionNode != null)
            retval.put(functionNode.getId(), functionNode.getProperty("name").toString());

        for (Node function : functionListGenerator.getSortedList(FunctionListGenerator.ALPHABETICAL, false)) {
            if (!(function.getRelationships(SimpleRelationshipType.withName("PERFORMS_FUNCTION")).iterator().hasNext()))
                retval.put(function.getId(), function.getProperty("name").toString());
        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, retval);
        return mav;
    }

    @RequestMapping(value = {"/fairview/ajax/set_task.do"})
    public ModelAndView setTask(@RequestParam("_nodeId") Long nodeId,
                                @RequestParam("title") String title,
                                @RequestParam(value = "assigned_to", required = false) Long assigned_to) {

        Node goalNode = neo.getNodeById(nodeId);
        Node taskNode = neo.createNode();

        taskNode.setProperty("title", title);
        taskNode.setProperty("nodeClass", "task");

        Relationship taskRelationship = goalNode.createRelationshipTo(taskNode, new SimpleRelationshipType("HAS_TASK"));

        if (assigned_to != null && assigned_to > 0l) {

            taskNode.createRelationshipTo(neo.getNodeById(assigned_to), new SimpleRelationshipType("ASSIGNED_TO"));

        } else {

            taskNode.createRelationshipTo(goalNode.getRelationships(SimpleRelationshipType.withName("HAS_GOAL"), Direction.INCOMING).iterator().next().getEndNode(), new SimpleRelationshipType("ASSIGNED_TO"));

        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, taskRelationship);

        return mav;

    }

    @RequestMapping(value = {"/fairview/ajax/set_goal.do"})
    public ModelAndView setGoal(@RequestParam("_nodeId") Long nodeId,
                                @RequestParam("title") String title,
                                @RequestParam("description") String description,
                                @RequestParam("measurement") String measurement,
                                @RequestParam("focus") String focus,
                                @RequestParam(value = "super_task", required = false) Long super_task) {

        Node node = neo.getNodeById(nodeId);
        Node goalNode = neo.createNode();

        Relationship goalRelationship = null;

        goalNode.setProperty("title", title);
        goalNode.setProperty("description", description);
        goalNode.setProperty("measurement", measurement);
        goalNode.setProperty("focus", focus);
        goalNode.setProperty("nodeClass", "goal");

        if (super_task != null && super_task > 0) {

            goalRelationship = neo.getNodeById(super_task).createRelationshipTo(goalNode, new SimpleRelationshipType("HAS_GOAL"));

        } else {

            goalRelationship = node.createRelationshipTo(goalNode, new SimpleRelationshipType("HAS_GOAL"));

        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, goalRelationship);

        return mav;

    }

    @RequestMapping(value = {"/fairview/ajax/revoke_admin.do"})
    public ModelAndView revokeAdmin(@RequestParam("_nodeId") Long nodeId) {

        Node userNode = neo.getNodeById(nodeId);

        for (Relationship relationship : userNode.getRelationships(new SimpleRelationshipType("HAS_ROLE"), Direction.OUTGOING)) {

            if (relationship.getEndNode().getProperty("authority", "").equals("ROLE_ADMIN")) {

                relationship.delete();

            }

        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, userNode);

        return mav;

    }

    @RequestMapping(value = {"/fairview/ajax/grant_admin.do"})
    public ModelAndView grantAdmin(@RequestParam("_nodeId") Long nodeId) {

        Node userNode = neo.getNodeById(nodeId);
        Node adminRoleNode = null;
        Relationship relationship = null;

        for (Node entry : neo.getAllNodes()) {

            if (entry.getProperty("authority", "").equals("ROLE_ADMIN")) {

                adminRoleNode = entry;
                break;

            }

        }

        if (adminRoleNode != null
                && userNode != null) {

            relationship = userNode.createRelationshipTo(adminRoleNode, new SimpleRelationshipType("HAS_ROLE"));

        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, relationship);

        return mav;

    }

    @RequestMapping(value = {"/fairview/ajax/is_admin.do"})
    public ModelAndView isAdmin(@RequestParam("_nodeId") Long nodeId) {

        Node userNode = neo.getNodeById(nodeId);
        Boolean isAdmin = false;

        for (Relationship relationship : userNode.getRelationships(new SimpleRelationshipType("HAS_ROLE"), Direction.OUTGOING)) {

            if (relationship.getEndNode().getProperty("authority", "").equals("ROLE_ADMIN")) {

                isAdmin = true;
                break;

            }

        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, isAdmin);

        return mav;

    }

    private Node getEndNode(Long endNodeId) {
        Node endNode;
        if (endNodeId == null) {
            endNode = neo.createNode();
        } else {
            endNode = neo.getNodeById(endNodeId);
        }
        return endNode;
    }

    @RequestMapping(value = {"/fairview/ajax/get_manager.do"})
    public ModelAndView getManager(@RequestParam("_unitId") long unitId) {

        Node unitNode = neo.getNodeById(unitId);

        Relationship managerRelationship = null;
        try {
            managerRelationship = ((Iterable<Relationship>) unitNode.getRelationships(SimpleRelationshipType.withName("HAS_MANAGER"), Direction.OUTGOING)).iterator().next();
        } catch (Exception ex) {
            // managerRelationship didn't exist
            long notFound = -1;
            ModelAndView mav = new ModelAndView(xstreamView);
            mav.addObject(XStreamView.XSTREAM_ROOT, notFound);
            return mav;
        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, managerRelationship.getEndNode().getId());

        return mav;
    }

    @RequestMapping(value = {"/fairview/ajax/get_relationship_endnodes.do"})
    public ModelAndView getRelationshipEndNodes(@RequestParam("_nodeId") long unitId, @RequestParam("_type") String type) {

        Node unitNode = neo.getNodeById(unitId);
        ArrayList<Node> retval = new ArrayList<Node>();

        for (Relationship relationship : unitNode.getRelationships(new SimpleRelationshipType(type), Direction.OUTGOING)) {
            retval.add(relationship.getEndNode());
        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, retval);
        return mav;
    }

    @RequestMapping(value = {"/fairview/ajax/get_organization_node.do"})
    public ModelAndView getOrganizationNode() {

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, organization);
        return mav;
    }

    @RequestMapping(value = {"/fairview/ajax/get_persons.do"})
    public ModelAndView getPersons() {

        PersonListGenerator personListGenerator = new PersonListGenerator((EmbeddedGraphDatabase) neo);
        ArrayList<Node> retval = personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, false);

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, retval);
        return mav;
    }

    @RequestMapping(value = {"/fairview/ajax/add_word.do"})
    public ModelAndView addWord(@RequestParam("category") String category,
                                             @RequestParam("value") String value) {
        if (dictionary.get(category) == null) {
            dictionary.put(category, new TreeSet<String>());
        }
        Boolean addedToDictionary = dictionary.get(category).add(value);
        getDictionaryNode().setProperty(category, dictionary.get(category));

        String response;
        if (addedToDictionary)
            response = "Added word '" + value + "' to category '" + category + "' of the dictionary.";
        else
            response = "Word '" + value + "' already exists in the dictionary.";

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, response);
        return mav;
    }

    @RequestMapping(value = {"/fairview/ajax/get_words.do"})
    public ModelAndView getWords(@RequestParam("category") String category) {
        ModelAndView mav = new ModelAndView(xstreamView);
        if (dictionary.get(category) == null) {
            try {
                dictionary.put(category, (TreeSet<String>) getDictionaryNode().getProperty(category));
            } catch (Exception e) {
                mav.addObject(XStreamView.XSTREAM_ROOT, "error: category " + category + " doesn't exist in the dictionary.");
                return mav;
            }
        }
        mav.addObject(XStreamView.XSTREAM_ROOT, dictionary.get(category));
        return mav;
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