package com.fairviewiq.spring.controllers;

import com.fairviewiq.utils.FunctionListGenerator;
import com.fairviewiq.utils.MultiSelectFunctionMember;
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
import se.codemate.spring.mvc.ModelMapConverter;
import se.codemate.spring.mvc.XStreamView;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.io.IOException;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

@Controller
public class FairviewAjaxController {

    @Resource
    private GraphDatabaseService neo;

    @Resource
    private NeoSearch neoSearch;

    private XStreamView xstreamView;
    private NeoUtils neoUtils;
    private FunctionListGenerator functionListGenerator;
    private Gson gson = new Gson();

    @PostConstruct
    public void initialize() {

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
            xstream.alias("node", Class.forName("org.neo4j.impl.core.NodeImpl"));
            xstream.alias("node", Class.forName("org.neo4j.impl.core.NodeProxy"));
        } catch (ClassNotFoundException e) {
            // no-op
        }

        try {
            xstream.alias("relationship", Class.forName("org.neo4j.impl.core.RelationshipImpl"));
            xstream.alias("relationship", Class.forName("org.neo4j.impl.core.RelationshipProxy"));
        } catch (ClassNotFoundException e) {
            // no-op
        }

        xstreamView = new XStreamView(xstream, "text/json");

        functionListGenerator = new FunctionListGenerator((EmbeddedGraphDatabase) neo);
    }

    @RequestMapping(value = {"/fairview/ajax/update_position.do"})
    public ModelAndView updatePropertyContainer(@RequestParam("_id") Long id,
                                                @RequestParam("name") String name,
                                                @RequestParam("reports_to") Long reportsTo) throws IOException {

        Node node = neo.getNodeById(id);

        node.setProperty("name", name);

        boolean relationshipExists = false;
        for (Relationship relationship : node.getRelationships(new SimpleRelationshipType("REPORTS_TO"), Direction.OUTGOING)) {
            if (relationship.getEndNode().getId() == reportsTo) {
                relationshipExists = true;
            } else {
                relationship.delete();
            }
        }

        if (!relationshipExists && reportsTo != -1) {
            node.createRelationshipTo(neo.getNodeById(reportsTo), new SimpleRelationshipType("REPORTS_TO"));
        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, node);
        return mav;

    }

    @RequestMapping(value = {"/fairview/ajax/assign_function.do"})
    public ModelAndView assignFunction(@RequestParam("employment") Long employmentId,
                                       @RequestParam("function:relationship") Long functionId,
                                       @RequestParam("percent") int percent) throws IOException {

        ModelAndView mav = new ModelAndView(xstreamView);

        Node employment = neo.getNodeById(employmentId);

        for (Relationship relationship : employment.getRelationships(new SimpleRelationshipType("PERFORMS_FUNCTION"), Direction.OUTGOING)) {
            if (relationship.getEndNode().getId() == functionId) {
                relationship.setProperty("percent", percent);
                mav.addObject(XStreamView.XSTREAM_ROOT, relationship);
                return mav;
            }
        }

        if (functionId != -1) {
            Relationship relationship = employment.createRelationshipTo(neo.getNodeById(functionId), new SimpleRelationshipType("PERFORMS_FUNCTION"));
            relationship.setProperty("percent", percent);
            mav.addObject(XStreamView.XSTREAM_ROOT, relationship);
        }

        return mav;

    }

    @RequestMapping(value = {"/fairview/ajax/assign_unit.do"})
    public ModelAndView assignUnit(@RequestParam("employment") Long employmentId,
                                   @RequestParam("unit:relationship") Long unitId,
                                   @RequestParam("percent") int percent) throws IOException {

        ModelAndView mav = new ModelAndView(xstreamView);

        Node employment = neo.getNodeById(employmentId);

        for (Relationship relationship : employment.getRelationships(new SimpleRelationshipType("ASSIGNED_UNIT"), Direction.OUTGOING)) {
            if (relationship.getEndNode().getId() == unitId) {
                relationship.setProperty("percent", percent);
                mav.addObject(XStreamView.XSTREAM_ROOT, relationship);
                return mav;
            }
        }

        if (unitId != -1) {
            Relationship relationship = employment.createRelationshipTo(neo.getNodeById(unitId), new SimpleRelationshipType("ASSIGNED_UNIT"));
            relationship.setProperty("percent", percent);
            mav.addObject(XStreamView.XSTREAM_ROOT, relationship);
        }

        return mav;

    }


    // Additions made by Henrik Enblom.

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

    @RequestMapping(value = {"/fairview/ajax/get_functionId.do"})
    public ModelAndView getFunction(@RequestParam("_nodeId") Long nodeId) {
        Node node = neo.getNodeById(nodeId);

        long functionId = getFunctionNodeId(node);
        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, functionId);
        return mav;
    }


    public static long getFunctionNodeId(Node employeeNode) {
        long functionId = -1;
        try {
            Traverser employmentTraverser = employeeNode.traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.OUTGOING);
            Traverser functionTraverser = employmentTraverser.iterator().next().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("PERFORMS_FUNCTION"), Direction.OUTGOING);
            functionId = functionTraverser.iterator().next().getId();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return functionId;
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

    private boolean functionBelongsToUnit(Node functionNode, long unitId) {

        boolean retval = false;

        for (Relationship relationship : functionNode.getRelationships(new SimpleRelationshipType("BELONGS_TO"), Direction.OUTGOING)) {

            if (relationship.getEndNode().getId() == unitId) {
                retval = true;
                break;
            }

        }

        return retval;

    }

    public static Node getUnitOfFunction(Node functionNode) {
        Node unitNode = null;
        try {
            Traverser unitTraverser = functionNode.traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("BELONGS_TO"), Direction.OUTGOING);
            unitNode = unitTraverser.iterator().next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return unitNode;
    }

    @RequestMapping(value = {"/fairview/ajax/unassign_function.do"})
    public ModelAndView getFunctionRelationshipId(@RequestParam("_nodeId") Long nodeId) {
        Node node = neo.getNodeById(nodeId);
        Set<Long> ids = new HashSet<Long>();
        try {
            Traverser employmentTraverser = node.traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.OUTGOING);
            if (employmentTraverser.iterator().hasNext()) {
                Node relationshipNode = employmentTraverser.iterator().next();
                ids = neoUtils.deleteNode(relationshipNode);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject("id", nodeId);
        mav.addObject("deleted", ids.size() > 0);
        mav.addObject("deletedIDs", ids);
        return mav;
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

    @RequestMapping(value = {"/fairview/ajax/update_goal.do"})
    public ModelAndView updateGoal(@RequestParam("_nodeId") Long nodeId,
                                   @RequestParam("title") String title,
                                   @RequestParam("description") String description,
                                   @RequestParam("measurement") String measurement,
                                   @RequestParam("focus") String focus,
                                   @RequestParam(value = "super_task", required = false) Long super_task) {

        Node goalNode = neo.getNodeById(nodeId);

        Relationship goalRelationship = null;

        goalNode.setProperty("title", title);
        goalNode.setProperty("description", description);
        goalNode.setProperty("measurement", measurement);
        goalNode.setProperty("focus", focus);
        goalNode.setProperty("nodeClass", "goal");

        if (super_task != null && super_task > 0) {

            goalNode.getRelationships(new SimpleRelationshipType("HAS_GOAL"), Direction.INCOMING).iterator().next().delete();

            goalRelationship = neo.getNodeById(super_task).createRelationshipTo(goalNode, new SimpleRelationshipType("HAS_GOAL"));

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


    @RequestMapping(value = {"/fairview/ajax/duplicate_function.do"})
    public ModelAndView duplicateNode(@RequestParam("_nodeId") Long nodeId,
                                      @RequestParam(value = "_destinationName", required = false) String destinationName) {

        Node sourceNode = neo.getNodeById(nodeId);
        Node destinationNode = neo.createNode();
        Node organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();

        for (String propertyKey : sourceNode.getPropertyKeys()) {

            if (!propertyKey.equals("UUID")) {

                destinationNode.setProperty(propertyKey, sourceNode.getProperty(propertyKey));

            }

        }

        if (destinationName == null) {

            destinationName = "";

            if (sourceNode.getProperty("name", "").equals("")) {

                sourceNode.setProperty("name", "Namnlös 1");
                destinationName = "Namnlös 2";

            } else {

                String sourceName = (String) sourceNode.getProperty("name");
                Integer increment = 1;

                String[] sourceNameParts = sourceName.split("\\s+");

                if (sourceNameParts[(sourceNameParts.length - 1)].matches("\\d$")) {

                    increment = (Integer.parseInt(sourceNameParts[(sourceNameParts.length - 1)].replaceAll("\\D", "")) + 1);

                    for (int i = 0; i < (sourceNameParts.length - 1); i++) {

                        destinationName += sourceNameParts[i];

                    }

                    destinationName += " " + increment;

                } else if (sourceName.substring(sourceName.length() - 1, sourceName.length()).matches("\\d")) {

                    increment = (Integer.parseInt(sourceName.substring(sourceName.length() - 1, sourceName.length())) + 1);

                    destinationName = sourceName.substring(0, sourceName.length() - 1) + increment;

                } else {

                    sourceNode.setProperty("name", sourceNode.getProperty("name") + " " + increment++);

                    destinationName = sourceName + " " + increment;

                }

                destinationNode.setProperty("name", destinationName);

            }

        }

        organization.createRelationshipTo(destinationNode, SimpleRelationshipType.withName("HAS_FUNCTION"));

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, destinationNode);

        return mav;

    }

    @RequestMapping(value = {"/fairview/ajax/assign_manager.do"})
    public ModelAndView assignManager(@RequestParam("_startNodeId") Long startNodeId,
                                      @RequestParam("_endNodeId") Long endNodeId) {

        Node unitNode = neo.getNodeById(startNodeId);
        deleteExistingManagerRelationship(unitNode);
        if (endNodeId == -1) // No boss selected
        {
            ModelAndView mav = new ModelAndView(xstreamView);
            mav.addObject(XStreamView.XSTREAM_ROOT, "Deleted manager of unit '" + unitNode.getProperty("name") + "'");
            return mav;
        } else {
            Node endNode = getEndNode(endNodeId);
            Relationship relationship = createManagerRelationship(unitNode, endNode);

            ModelAndView mav = new ModelAndView(xstreamView);
            mav.addObject(XStreamView.XSTREAM_ROOT, relationship);
            return mav;
        }
    }

    private Relationship createManagerRelationship(Node unitNode, Node endNode) {
        return unitNode.createRelationshipTo(endNode, new SimpleRelationshipType("HAS_MANAGER"));
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

    private void deleteExistingManagerRelationship(Node unitNode) {
        Relationship managerRelationship = null;
        try {
            managerRelationship = ((Iterable<Relationship>) unitNode.getRelationships(SimpleRelationshipType.withName("HAS_MANAGER"), Direction.OUTGOING)).iterator().next();
        } catch (Exception ex) {
            // managerRelationship didn't exist
        }
        if (managerRelationship != null) {
            managerRelationship.delete();  //if unit already has a Manager, delete it
        }
    }

    @RequestMapping(value = {"/fairview/ajax/get_manager.do"})
    public ModelAndView getManager(@RequestParam("_unitId") long unitId) {

        Node unitNode = neo.getNodeById(unitId);

        Relationship managerRelationship = null;
        try {
            managerRelationship = ((Iterable<Relationship>) unitNode.getRelationships(SimpleRelationshipType.withName("HAS_MANAGER"), Direction.OUTGOING)).iterator().next();
        } catch (Exception ex) {
            // managerRelationship didn't exist
            long noFind = -1;
            ModelAndView mav = new ModelAndView(xstreamView);
            mav.addObject(XStreamView.XSTREAM_ROOT, noFind);
            return mav;
        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, managerRelationship.getEndNode().getId());

        return mav;
    }


    @RequestMapping(value = {"/fairview/ajax/get_multiselect_functions.do"})
    public ModelAndView getMultiselectFunctions(@RequestParam("_unitId") long unitId) {

        ArrayList<Node> functions = functionListGenerator.getSortedList(0, true);
        ArrayList<MultiSelectFunctionMember> msfList = new ArrayList<MultiSelectFunctionMember>();
        for (Node function : functions) {

            MultiSelectFunctionMember multiSelectFunction = new MultiSelectFunctionMember(function.getProperty("name").toString(), function.getId());
            if (functionBelongsToUnit(function, unitId)) {

                multiSelectFunction.setSelected(true);

            }
            msfList.add(multiSelectFunction);
        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, msfList);
        return mav;
    }

    @RequestMapping(value = {"/fairview/ajax/set_multiselect_functions.do"})
    public ModelAndView setMultiselectFunctions(@RequestParam("_unitId") long unitId,
                                                @RequestParam("_functionIds") String functionIds) {

        Long[] functionIdArray = gson.fromJson(functionIds, Long[].class);

        Node unitNode = neo.getNodeById(unitId);

        for (Relationship relationship : unitNode.getRelationships(new SimpleRelationshipType("BELONGS_TO"), Direction.INCOMING)) {
            relationship.delete();
        }

        for (Long entry : functionIdArray) {
            neo.getNodeById(entry).createRelationshipTo(unitNode, new SimpleRelationshipType("BELONGS_TO"));
        }

        ModelAndView mav = new ModelAndView(xstreamView);
        return mav;
    }

    @RequestMapping(value = {"/fairview/ajax/get_languages.do"})
    public ModelAndView getLanguages(@RequestParam("_nodeId") long unitId) {

        Node unitNode = neo.getNodeById(unitId);
        ArrayList<Node> retval = new ArrayList<Node>();

        for (Relationship relationship : unitNode.getRelationships(new SimpleRelationshipType("HAS_LANGUAGESKILL"), Direction.OUTGOING)) {
            retval.add(relationship.getEndNode());
        }

        ModelAndView mav = new ModelAndView(xstreamView);
        mav.addObject(XStreamView.XSTREAM_ROOT, retval);
        return mav;
    }


}



