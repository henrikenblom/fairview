package com.fairviewiq.cloner;

import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.kernel.EmbeddedGraphDatabase;
import org.neo4j.kernel.EmbeddedReadOnlyGraphDatabase;

public class Main {
    public static void main(String[] args) {

        GraphDatabaseService neoIn = new EmbeddedReadOnlyGraphDatabase(args[0]);
        GraphDatabaseService neoOut = new EmbeddedGraphDatabase(args[1]);

        neoIn.shutdown();
        neoOut.shutdown();

    }
}
