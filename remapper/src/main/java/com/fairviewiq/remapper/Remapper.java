package com.fairviewiq.remapper;

import org.neo4j.graphdb.*;
import org.neo4j.kernel.EmbeddedGraphDatabase;

import java.io.IOException;
import java.util.Set;
import java.util.TreeSet;

public class Remapper {

    private GraphDatabaseService neo;
    private String from;
    private String to;

    public Remapper(EmbeddedGraphDatabase neo, String from, String to) throws ClassNotFoundException, IOException {
        this.neo = neo;
        this.from = from;
        this.to = to;
    }

    public void remap() {
        Transaction tx = neo.beginTx();
        try {
            for (Node node : neo.getAllNodes()) {
                if (node.hasProperty(from)) {
                    System.out.println("[N] "+node.getId() + " " + from + " -> " + to + " : " + node.getProperty(from));
                    node.setProperty(to, node.removeProperty(from));
                }
                for (Relationship relationship : node.getRelationships(Direction.OUTGOING)) {
                    if (relationship.hasProperty(from)) {
                        System.out.println("[R] "+relationship.getId() + " " + from + " -> " + to + " : " + relationship.getProperty(from));
                        relationship.setProperty(to, relationship.removeProperty(from));
                    }
                }
            }
            tx.success();
        } finally {
            tx.finish();
        }
    }

    public void shutdown() {
        neo.shutdown();
    }

    public static void main(String[] args) throws Exception {
        EmbeddedGraphDatabase neo = new EmbeddedGraphDatabase(args[0]);
        Remapper remapper = new Remapper(neo, args[1], args[2]);
        remapper.remap();
        remapper.shutdown();
    }

}
