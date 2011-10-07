package com.fairviewiq.cloner;

import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.io.xml.DomDriver;
import org.neo4j.graphdb.*;
import org.neo4j.kernel.EmbeddedGraphDatabase;
import org.neo4j.kernel.EmbeddedReadOnlyGraphDatabase;
import se.codemate.neo4j.SimpleRelationshipType;
import se.codemate.neo4j.XStreamEmbeddedNeoConverter;
import se.codemate.neo4j.XStreamNodeConverter;
import se.codemate.neo4j.XStreamRelationshipConverter;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.util.*;

/*
Notes
1a. For units, managerorganizationForm should be called manager in v 11.1
1b. Why is manager stored as a field when it exists as a relationship?
2. Where can we add emp. id? (anst. nr)
 */

public class Cloner {

    private GraphDatabaseService neoIn;
    private GraphDatabaseService neoOut;

    private Map<Long, Long> idMap = new HashMap<Long, Long>();
    private XStream xstream = new XStream(new DomDriver());

    public Cloner(String initPath, EmbeddedReadOnlyGraphDatabase neoIn, EmbeddedGraphDatabase neoOut) throws ClassNotFoundException, IOException {

        this.neoIn = neoIn;
        this.neoOut = neoOut;
        Node inReferenceNode = neoIn.getReferenceNode();
        Node outReferenceNode = neoOut.getReferenceNode();
        idMap.put(inReferenceNode.getId(), outReferenceNode.getId());

        Transaction tx = neoOut.beginTx();
        try {
            Node node = neoOut.getNodeById(0);
            XStream xstreamInit = new XStream();
            xstreamInit.setMode(XStream.NO_REFERENCES);
            xstreamInit.alias("embeddedNeo", EmbeddedGraphDatabase.class);
            xstreamInit.alias("node", Node.class);
            xstreamInit.alias("node", Class.forName("org.neo4j.kernel.impl.core.NodeImpl"));
            xstreamInit.alias("node", Class.forName("org.neo4j.kernel.impl.core.NodeProxy"));
            xstreamInit.alias("relationship", Relationship.class);
            xstreamInit.alias("relationship", Class.forName("org.neo4j.kernel.impl.core.RelationshipImpl"));
            xstreamInit.alias("relationship", Class.forName("org.neo4j.kernel.impl.core.RelationshipProxy"));
            xstreamInit.registerConverter(new XStreamEmbeddedNeoConverter(neoOut));
            xstreamInit.registerConverter(new XStreamNodeConverter(xstreamInit.getMapper()));
            xstreamInit.registerConverter(new XStreamRelationshipConverter(xstreamInit.getMapper()));
            ObjectInputStream in = xstreamInit.createObjectInputStream(new FileInputStream(initPath));
            in.readObject();
            in.close();
            setProperty(node, "initialized", true);
            tx.success();
        } finally {
            tx.finish();
        }

    }

    public void cloneOrganization() {

        /* Copy the node */
        Node inReferenceNode = neoIn.getReferenceNode();
        Relationship relationship1 = inReferenceNode.getSingleRelationship(new SimpleRelationshipType("HAS_ORGANIZATION"), Direction.OUTGOING);
        Node organization = relationship1.getEndNode();
        Relationship relationship2 = organization.getSingleRelationship(new SimpleRelationshipType("HAS_ADDRESS"), Direction.OUTGOING);
        Node address = relationship2.getEndNode();
        Map<String, Object> properties = new TreeMap<String, Object>();
        addMultipleIfExists(organization, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED", "name", "description", "regnr", "phone", "fax", "email", "web"}, properties);
        addMultipleIfExists(address, new String[]{"address", "postalcode", "city", "country"}, properties);
        idMap.put(organization.getId(), createNode(properties));

        /* Create the link */
        createLink(relationship1);

    }

    public void cloneEmployees() {

        ReturnableEvaluator returnEvaluator = new ReturnableEvaluator() {
            public boolean isReturnableNode(TraversalPosition position) {
                return position.depth() > 1;
            }
        };

        Traverser employees = neoIn.getReferenceNode().traverse(Traverser.Order.BREADTH_FIRST,
                StopEvaluator.END_OF_GRAPH, returnEvaluator,
                new SimpleRelationshipType("HAS_ORGANIZATION"), Direction.OUTGOING,
                new SimpleRelationshipType("HAS_EMPLOYEE"), Direction.OUTGOING);

        for (Node employee : employees) {
            Map<String, Object> properties = new TreeMap<String, Object>();
            addMultipleIfExists(employee, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED", "firstname", "lastname", "email"}, properties);
            if (properties.containsKey("firstname")) {
                idMap.put(employee.getId(), createNode(properties));
                createLink(employee.getSingleRelationship(new SimpleRelationshipType("HAS_EMPLOYEE"), Direction.INCOMING));
            }
        }

    }

    public void cloneUnits() {

        ReturnableEvaluator returnEvaluator = new ReturnableEvaluator() {
            public boolean isReturnableNode(TraversalPosition position) {
                return position.depth() > 1;
            }
        };

        Traverser traverser = neoIn.getReferenceNode().traverse(Traverser.Order.BREADTH_FIRST,
                StopEvaluator.END_OF_GRAPH, returnEvaluator,
                new SimpleRelationshipType("HAS_ORGANIZATION"), Direction.OUTGOING,
                new SimpleRelationshipType("HAS_UNIT"), Direction.OUTGOING);

        Set<Node> units = new HashSet<Node>();
        for (Node unit : traverser) {
            units.add(unit);
        }

        for (Node unit : units) {

            /* Copy the unit node */
            Map<String, Object> properties = new TreeMap<String, Object>();
            addMultipleIfExists(unit, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED", "name", "description", "phone", "fax", "email", "web", "address", "postalcode", "city", "country"}, properties);
            idMap.put(unit.getId(), createNode(properties));

            /* Link the unit to the manager */
            createLink(unit.getSingleRelationship(new SimpleRelationshipType("HAS_MANAGER"), Direction.OUTGOING));

        }

        for (Node unit : units) {
            /* Link the unit to sub units */
            for (Relationship relationship : unit.getRelationships(new SimpleRelationshipType("HAS_UNIT"), Direction.INCOMING)) {
                createLink(relationship);
            }
        }

    }

    private void addMultipleIfExists(PropertyContainer propertyContainer, String[] inputNames, Map<String, Object> properties) {
        for (String inputName : inputNames) {
            addIfExists(propertyContainer, inputName, properties);
        }
    }

    private void addIfExists(PropertyContainer propertyContainer, String inputName, Map<String, Object> properties) {
        addIfExists(propertyContainer, inputName, inputName, properties);
    }

    private void addIfExists(PropertyContainer propertyContainer, String inputName, String outputName, Map<String, Object> properties) {
        if (propertyContainer != null) {
            Object value = propertyContainer.getProperty(inputName, null);
            if (value != null) {
                properties.put(outputName, value);
            }
        }
    }

    private void createLink(Relationship inRelationship) {
        if (inRelationship != null) {
            createLink(inRelationship, inRelationship.getType().name());
        }
    }

    private void createLink(Relationship inRelationship, String type) {
        if (inRelationship != null) {
            Map<String, Object> properties = new TreeMap<String, Object>();
            addMultipleIfExists(inRelationship, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED"}, properties);
            createLink(inRelationship, type, properties);
        }
    }

    private void createLink(Relationship inRelationship, String type, Map<String, Object> properties) {
        if (inRelationship != null) {
            createLink(inRelationship.getStartNode(), inRelationship.getEndNode(), type, properties);
        }
    }

    private void createLink(Node inFrom, Node inTo, String type, Map<String, Object> properties) {
        Transaction tx = neoOut.beginTx();
        try {
            Node outFrom = neoOut.getNodeById(idMap.get(inFrom.getId()));
            Node outTo = neoOut.getNodeById(idMap.get(inTo.getId()));
            Relationship relationship = outFrom.createRelationshipTo(outTo, new SimpleRelationshipType(type));
            System.out.println("L " + inFrom.getId() + "->" + inTo.getId() + " | " + outFrom.getId() + "-[" + type + "]->" + outTo.getId() + " = " + relationship.getId());
            for (String key : properties.keySet()) {
                Object value = properties.get(key);
                setProperty(relationship, key, value);
                System.out.println("L " + relationship.getId() + ":" + key + " = " + value);
            }
            tx.success();
        } finally {
            tx.finish();
        }
    }

    private long createNode(Map<String, Object> properties) {
        Transaction tx = neoOut.beginTx();
        try {
            Node node = neoOut.createNode();
            for (String key : properties.keySet()) {
                Object value = properties.get(key);
                setProperty(node, key, value);
                System.out.println("N " + node.getId() + ":" + key + " = " + value);
            }
            tx.success();
            return node.getId();
        } finally {
            tx.finish();
        }
    }

    private long cloneNode(Node node) {
        return cloneNode(node, null);
    }

    private long cloneNode(Node node, Map<String, String> fieldMap) {
        Map<String, Object> properties = new TreeMap<String, Object>();
        for (String key : node.getPropertyKeys()) {
            Object value = node.getProperty(key);
            String mappedKey = (fieldMap != null && fieldMap.containsKey(key)) ? fieldMap.get(key) : key;
            properties.put(mappedKey, value);
        }
        return createNode(properties);
    }

    private void setProperty(PropertyContainer propertyContainer, String key, Object value) {
        if (Cloner.isValidType(value)) {
            propertyContainer.setProperty(key, value);
        } else {
            propertyContainer.setProperty(key, "XStream:" + xstream.toXML(value));
        }
    }

    public void shutdown() {
        neoIn.shutdown();
        neoOut.shutdown();
    }

    private static void deleteDir(File dir) {
        if (dir.isDirectory()) {
            for (File file : dir.listFiles()) {
                deleteDir(file);
            }
        }
        dir.delete();
    }

    private static boolean isValidType(Object object) {
        Class type = object.getClass();
        if (type.isArray()) {
            type = type.getComponentType();
        }
        return Boolean.class.equals(type) ||
                Byte.class.equals(type) ||
                Short.class.equals(type) ||
                Integer.class.equals(type) ||
                Long.class.equals(type) ||
                Float.class.equals(type) ||
                Double.class.equals(type) ||
                Character.class.equals(type) ||
                String.class.equals(type);
    }

    public static void main(String[] args) throws Exception {

        deleteDir(new File(args[2]));

        EmbeddedReadOnlyGraphDatabase neoIn = new EmbeddedReadOnlyGraphDatabase(args[1]);
        EmbeddedGraphDatabase neoOut = new EmbeddedGraphDatabase(args[2]);

        Cloner cloner = new Cloner(args[0], neoIn, neoOut);
        cloner.cloneOrganization();
        cloner.cloneEmployees();
        cloner.cloneUnits();
        cloner.shutdown();

    }

}