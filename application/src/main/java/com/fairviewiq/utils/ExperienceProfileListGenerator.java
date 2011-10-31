package com.fairviewiq.utils;

import org.neo4j.graphdb.Direction;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.kernel.EmbeddedGraphDatabase;
import se.codemate.neo4j.SimpleRelationshipType;

import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 10/25/11
 * Time: 9:31 AM
 * To change this template use File | Settings | File Templates.
 */
public class ExperienceProfileListGenerator {
    private EmbeddedGraphDatabase neo;

    public ExperienceProfileListGenerator(EmbeddedGraphDatabase neo) {

        this.neo = neo;

    }

    public ArrayList<Node> getExperienceProfiles() {

        ArrayList<Node> retval = new ArrayList<Node>();

        Node organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();

        for (Relationship relationship : organization.getRelationships(SimpleRelationshipType.withName("HAS_EXPERIENCE_PROFILE"), Direction.OUTGOING)) {
            try {
                retval.add(relationship.getEndNode());
            } catch (Exception e) {
                //no-op
            }
        }
        return retval;
    }
}
