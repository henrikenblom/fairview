package com.fairviewiq.utils;

import org.neo4j.graphdb.Direction;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.kernel.EmbeddedGraphDatabase;
import se.codemate.neo4j.SimpleRelationshipType;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;

/**
 * Created by IntelliJ IDEA.
 * User: danielwallerius
 * Date: 2011-09-27
 * Time: 09.35
 * To change this template use File | Settings | File Templates.
 */
public class EmploymentListGenerator {
    private EmbeddedGraphDatabase neo;

    public EmploymentListGenerator(EmbeddedGraphDatabase neo){

        this.neo = neo;

    }
    public ArrayList<Node> getEmployments(){

        ArrayList<Node> retval = new ArrayList<Node>();

        Node organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();

        for (Relationship relationship : organization.getRelationships(SimpleRelationshipType.withName("HAS_EMPLOYEE"), Direction.OUTGOING)){

            try {
                retval.add(relationship.getEndNode().getRelationships(SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.OUTGOING).iterator().next().getEndNode());
            } catch (Exception ex) {
                // no-op
            }
        }

          return retval;

    }
}


