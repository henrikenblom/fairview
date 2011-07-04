package com.fairviewiq.spring.controllers;

import org.apache.commons.io.IOUtils;
import org.apache.lucene.queryParser.ParseException;
import org.codehaus.jettison.json.JSONArray;
import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;
import org.neo4j.graphdb.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;
import se.codemate.neo4j.SimpleRelationshipType;
import se.codemate.neo4j.NeoSearch;
import se.codemate.neo4j.NeoUtils;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

@Controller
public class WireitController {

    @Resource
    private GraphDatabaseService neo;

    @Resource
    private NeoSearch neoSearch;

    @RequestMapping(value = {"/neo/ajax/wiring_rpc.do"})
    public void rpc(HttpServletRequest request, HttpServletResponse response) throws JSONException, IOException {

        String data = IOUtils.toString(request.getReader());

        JSONObject rpcObject = new JSONObject(data);

        JSONObject responseObject = new JSONObject();
        responseObject.put("id", rpcObject.getString("id"));

        String method = rpcObject.getString("method");

        if ("listWirings".equals(method)) {
            JSONArray wiringsArray = new JSONArray();
            Relationship relationship = neo.getReferenceNode().getSingleRelationship(new SimpleRelationshipType("HAS_ORGANIZATION"), Direction.OUTGOING);
            if (relationship != null) {
                Node organization = relationship.getEndNode();
                if (organization.hasProperty("wiring")) {
                    JSONObject wiringObject = new JSONObject();
                    wiringObject.put("id", "1");
                    wiringObject.put("name", "organization");
                    wiringObject.put("working", new JSONObject((String) organization.getProperty("wiring")).toString());
                    wiringObject.put("language", "fairview");
                    wiringObject.put("readonly", "0");
                    wiringsArray.put(wiringObject);
                }
            }
            responseObject.put("result", wiringsArray);
        } else if ("saveWiring".equals(method)) {

            LinkedList<Long> orphans = new LinkedList<Long>();
            try {
                for (Node node : neoSearch.getNodes("nodeClass:unit")) {
                    orphans.add(node.getId());
                }
            } catch (ParseException e) {
                // Todo: warn!
            }

            JSONObject workingObject = new JSONObject(rpcObject.getJSONObject("params").getString("working"));

            Node organization = null;

            JSONArray modules = workingObject.getJSONArray("modules");
            for (int i = 0; i < modules.length(); i++) {
                JSONObject module = modules.getJSONObject(i);
                JSONObject values = module.getJSONObject("value");
                if ("Start".equalsIgnoreCase(module.optString("name", null))) {
                    Relationship relationship = neo.getReferenceNode().getSingleRelationship(new SimpleRelationshipType("HAS_ORGANIZATION"), Direction.OUTGOING);
                    if (relationship != null) {
                        organization = relationship.getEndNode();
                        module.put("node", organization);
                    }
                } else {
                    if (values.has("id")) {
                        Node node;
                        if (values.getString("id") != null && values.getString("id").trim().length() == 0) {
                            node = neo.createNode();
                            values.put("id", node.getId());
                        } else {
                            try {
                                node = neo.getNodeById(values.getLong("id"));
                                orphans.remove(node.getId());
                            } catch (NotFoundException e) {
                                node = neo.createNode();
                                values.put("id", node.getId());
                            }
                        }
                        node.setProperty("nodeClass", values.has("address") ? "address" : "unit");
                        module.put("INBOUND_RELATIONSHIP_TYPE", values.has("address") ? "HAS_ADDRESS" : "HAS_UNIT");
                        module.put("node", node);
                        Iterator iterator = values.keys();
                        while (iterator.hasNext()) {
                            String key = (String) iterator.next();
                            String value = values.optString(key, null);
                            if (value != null && !"id".equals(key)) {
                                if (value.length() == 0) {
                                    node.removeProperty(key);
                                } else {
                                    node.setProperty(key, value);
                                }
                            }
                        }
                        for (Relationship relationship : node.getRelationships()) {
                            relationship.delete();
                        }
                    }
                }
            }

            if (organization != null) {
                organization.setProperty("wiring", workingObject.toString());
            }

            JSONArray wires = workingObject.getJSONArray("wires");
            for (int i = 0; i < wires.length(); i++) {
                JSONObject wire = wires.getJSONObject(i);
                JSONObject sourceModule = modules.getJSONObject(wire.getJSONObject("src").getInt("moduleId"));
                JSONObject targetModule = modules.getJSONObject(wire.getJSONObject("tgt").getInt("moduleId"));
                if (sourceModule.has("node") && targetModule.has("node")) {
                    Node source = (Node) sourceModule.get("node");
                    Node target = (Node) targetModule.get("node");
                    RelationshipType relationshipType = new SimpleRelationshipType(targetModule.getString("INBOUND_RELATIONSHIP_TYPE"));
                    source.createRelationshipTo(target, relationshipType);
                }
            }

            NeoUtils neoUtils = new NeoUtils(neo);
            while (orphans.size() > 0) {
                orphans.removeAll(neoUtils.deleteNode(neo.getNodeById(orphans.removeFirst())));
            }

            responseObject.put("result", true);

        }

        response.setContentType("text/json; charset=UTF-8");
        responseObject.write(response.getWriter());

    }

}
