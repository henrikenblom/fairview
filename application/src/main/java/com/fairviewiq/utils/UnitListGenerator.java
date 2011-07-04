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
public class UnitListGenerator {

    public static final int UNORDERED = 0;
    public static final int ALPHABETICAL = 1;

    private Node organization;
    private EmbeddedGraphDatabase neo;

    public UnitListGenerator(EmbeddedGraphDatabase neo) {

        this.neo = neo;
        organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();

    }

    public  ArrayList<Node> getSortedList(int sortOrder, boolean descending) {

        ArrayList<Node> retval = new ArrayList<Node>();
        HashMap<String, Node> unorderedUnitMap = new HashMap<String, Node>();
        ArrayList<String> unitKeys = new ArrayList<String>();
        ArrayList<Node> zombieNodes = new ArrayList<Node>();

        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"), Direction.OUTGOING)) {

            if (!entry.getEndNode().getProperty("name", "").equals("")) {

                unorderedUnitMap.put(entry.getEndNode().getProperty("name", "") + "_" + entry.getEndNode().getId(), entry.getEndNode());
                unitKeys.add(entry.getEndNode().getProperty("name", "") + "_" + entry.getEndNode().getId());

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

            Collections.sort(unitKeys);

        }

        if (descending) {

            Collections.reverse(unitKeys);

        }

        for (String key : unitKeys) {

            retval.add(unorderedUnitMap.get(key));

        }

        unorderedUnitMap = null;
        unitKeys = null;

        return retval;

    }

}
