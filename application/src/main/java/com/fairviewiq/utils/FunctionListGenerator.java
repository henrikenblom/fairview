package com.fairviewiq.utils;

import org.neo4j.graphdb.Direction;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.kernel.EmbeddedGraphDatabase;
import se.codemate.neo4j.SimpleRelationshipType;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

/**
 * Created by IntelliJ IDEA.
 * User: henrik
 * Date: 2011-01-25
 * Time: 10.22
 * To change this template use File | Settings | File Templates.
 */
public class FunctionListGenerator {

    public static final int UNORDERED = 0;
    public static final int ALPHABETICAL = 1;

    private EmbeddedGraphDatabase neo;

    public FunctionListGenerator(EmbeddedGraphDatabase neo) {

        this.neo = neo;

    }

    public  ArrayList<Node> getSortedList(int sortOrder, boolean descending) {

        ArrayList<Node> retval = new ArrayList<Node>();
        HashMap<String, Node> unorderedFunctionMap = new HashMap<String, Node>();
        ArrayList<String> functionKeys = new ArrayList<String>();
        ArrayList<Node> zombieNodes = new ArrayList<Node>();

        Node organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();

        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_FUNCTION"), Direction.OUTGOING)) {

            if (!entry.getEndNode().getProperty("name", "").equals("")) {

                unorderedFunctionMap.put(entry.getEndNode().getProperty("name", "") + "_" + entry.getEndNode().getId(), entry.getEndNode());
                functionKeys.add(entry.getEndNode().getProperty("name", "") + "_" + entry.getEndNode().getId());

            } else {

                zombieNodes.add(entry.getEndNode());

            }

        }

        //Transaction tx = neo.beginTx();

        //try {

        //   for (Node zombie : zombieNodes) {

        //        zombie.delete();

        //    }

        //    tx.success();

        //} catch (Exception ex) {

        //    tx.finish();
        //    tx = null;

        //}

        if (sortOrder == ALPHABETICAL) {

            Collections.sort(functionKeys);

        }

        if (descending) {

            Collections.reverse(functionKeys);

        }

        for (String key : functionKeys) {

            retval.add(unorderedFunctionMap.get(key));

        }

        unorderedFunctionMap = null;
        functionKeys = null;

        return retval;

    }

}
