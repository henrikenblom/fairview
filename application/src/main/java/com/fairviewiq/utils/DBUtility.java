package com.fairviewiq.utils;

import org.neo4j.graphdb.*;
import se.codemate.neo4j.SimpleRelationshipType;

import javax.annotation.Resource;

/**
 * Created by IntelliJ IDEA.
 * User: danielwallerius
 * Date: 2011-09-22
 * Time: 14.39
 * To change this template use File | Settings | File Templates.
 */
public class DBUtility {

    private GraphDatabaseService neo;

    private static DBUtility ourInstance = null;

    public static DBUtility getInstance(GraphDatabaseService neo) {

        if (ourInstance == null) {
            ourInstance = new DBUtility(neo);
        }

        return ourInstance;
    }

    private DBUtility(GraphDatabaseService neo) {

        this.neo = neo;

    }

    public Node getUnitOfEmployment(Node employmentNode) {

        Node unitNode = null;

        try {

            Traverser unitTraverser = employmentNode.traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("BELONGS_TO"), Direction.OUTGOING);
            unitNode = unitTraverser.iterator().next();

        } catch (Exception e) {

            try {
                unitNode = getOrganizationNode();
            } catch (Exception ex) {

                //no-op

            }

        }

        return unitNode;
    }


    private Node getOrganizationNode() throws Exception {

        return ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();

    }

}
