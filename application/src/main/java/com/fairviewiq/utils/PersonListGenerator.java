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
public class PersonListGenerator {

    public static final int UNORDERED = 0;
    public static final int ALPHABETICAL = 1;

    private Node organization;
    private EmbeddedGraphDatabase neo;

    public PersonListGenerator(EmbeddedGraphDatabase neo) {

        this.neo = neo;
        organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();

    }

    public  ArrayList<Node> getSortedList(int sortOrder, boolean descending) {

        HashMap<String, Node> unorderedEmployeeMap = new HashMap<String, Node>();
        ArrayList<String> employeeNames = new ArrayList<String>();
        ArrayList<Node> retval = new ArrayList<Node>();
        ArrayList<Node> zombieNodes = new ArrayList<Node>();

        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_EMPLOYEE"), Direction.OUTGOING)) {

            try {

                if (!entry.getEndNode().getProperty("lastname", "").equals("") || !entry.getEndNode().getProperty("firstname", "").equals("")) {

                    String coworkerKey = entry.getEndNode().getProperty("lastname", "") + "_" + entry.getEndNode().getProperty("firstname","") + "_" + entry.getEndNode().getId();

                    unorderedEmployeeMap.put(coworkerKey, entry.getEndNode());
                    employeeNames.add(coworkerKey);

                } else {

                    zombieNodes.add(entry.getEndNode());

                }

            } catch (IllegalStateException ex) {
                // noop
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

            Collections.sort(employeeNames);

        }

        if (descending) {

            Collections.reverse(employeeNames);

        }

        for (String key : employeeNames) {

            retval.add(unorderedEmployeeMap.get(key));

        }

        unorderedEmployeeMap = null;
        employeeNames = null;
        zombieNodes = null;

        return retval;

    }

}
