package com.fairviewiq.cloner;

import org.neo4j.graphdb.*;
import org.neo4j.kernel.EmbeddedGraphDatabase;
import org.neo4j.kernel.EmbeddedReadOnlyGraphDatabase;
import se.codemate.neo4j.SimpleRelationshipType;

import java.util.HashMap;
import java.util.Map;

public class Cloner {

    private GraphDatabaseService neoIn;
    private GraphDatabaseService neoOut;

    private Map<Long, Long> idMap = new HashMap<Long, Long>();

    public Cloner(GraphDatabaseService neoIn, GraphDatabaseService neoOut) {
        this.neoIn = neoIn;
        this.neoOut = neoOut;
    }

    public void cloneOrganization() {
        Node root = neoIn.getReferenceNode();
        Relationship relationship = root.getSingleRelationship(new SimpleRelationshipType("HAS_ORGANIZATION"), Direction.OUTGOING);
        idMap.put(relationship.getEndNode().getId(), cloneNode(relationship.getEndNode()));
    }

    private long cloneNode(Node node) {
        return cloneNode(node, null);
    }

    private long cloneNode(Node node, Map<String, String> fieldMap) {
        Transaction tx = neoOut.beginTx();
        try {
            Node newNode = neoOut.createNode();
            System.out.println(node.getId() + ":" + newNode.getId());
            for (String key : node.getPropertyKeys()) {
                Object value = node.getProperty(key);
                String newKey = (fieldMap != null && fieldMap.containsKey(key)) ? fieldMap.get(key) : key;
                newNode.setProperty(newKey, value);
                System.out.println("  " + key + " -> " + newKey + " = " + value);
            }
            tx.success();
            return newNode.getId();
        } finally {
            tx.finish();
        }
    }

    public void shutdown() {
        neoIn.shutdown();
        neoOut.shutdown();
    }

    public static void main(String[] args) {

        GraphDatabaseService neoIn = new EmbeddedReadOnlyGraphDatabase(args[0]);
        GraphDatabaseService neoOut = new EmbeddedGraphDatabase(args[1]);

        Cloner cloner = new Cloner(neoIn, neoOut);
        cloner.cloneOrganization();
        cloner.shutdown();

    }

}
