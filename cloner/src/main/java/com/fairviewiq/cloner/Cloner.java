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
import java.text.DateFormat;
import java.text.SimpleDateFormat;
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
    private static DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    private HashMap<String, Integer> skillLevel = new HashMap<String, Integer>();

    private Map<Long, Long> idMap = new HashMap<Long, Long>();
    private XStream xstream = new XStream(new DomDriver());
    private DateTool dateTool = DateTool.getInstance();

    public Cloner(String initPath, EmbeddedReadOnlyGraphDatabase neoIn, EmbeddedGraphDatabase neoOut) throws ClassNotFoundException, IOException {

        skillLevel.put("Viss", 1);
        skillLevel.put("God", 2);
        skillLevel.put("Avancerad", 3);

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
        addMultipleIfExists(organization, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED",
                "address", "city", "country", "description", "email", "fax", "imageurl", "name", "phone", "postalcode", "regnr", "web"

        }, properties);
        addMultipleIfExists(address, new String[]{"address", "postalcode", "city", "country"}, properties);

        properties.put("nodeclass", "organization");

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
            addMultipleIfExists(employee, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED",
                    "firstname", "lastname", "email", "address", "birthday", "cell", "city", "civic", "country",
                    "gender", "nationality", "phone", "zip", "additional_info"
            }, properties);

            properties.put("nodeclass", "employee");

            if (properties.containsKey("firstname")) {
                idMap.put(employee.getId(), createNode(properties));
                createLink(employee.getSingleRelationship(new SimpleRelationshipType("HAS_EMPLOYEE"), Direction.INCOMING));
                createLink(employee.getSingleRelationship(new SimpleRelationshipType("BELONGS_TO"), Direction.OUTGOING));
            }
        }

    }

    public void createEmployments() {

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

            Node oldEmploymentNode = null;
            Node oldFunctionNode = null;

            Map<String, Object> properties = new TreeMap<String, Object>();

            try {

                oldEmploymentNode = employee.getSingleRelationship(new SimpleRelationshipType("HAS_EMPLOYMENT"), Direction.OUTGOING).getEndNode();

            } catch (Exception ex) {

                System.err.println("Employee node " + employee.getId() + " has no employment/function relationship.");

            }

            if (oldEmploymentNode != null) {

                oldFunctionNode = oldEmploymentNode.getSingleRelationship(new SimpleRelationshipType("PERFORMS_FUNCTION"), Direction.OUTGOING).getEndNode();

                properties.put("authorizationamount", toInt(employee.getProperty("authorization-amount", "0")));
                properties.put("authorizationright", employee.getProperty("authorization", ""));
                properties.put("budgetresponsibility", employee.getProperty("budget-responsibility", ""));
                properties.put("companycar", employee.getProperty("company-car", ""));
                properties.put("dismissalperiodemployee", toInt(employee.getProperty("dismissal-period-employee", "")));
                properties.put("dismissalperiodemployeer", toInt(employee.getProperty("dismissal-period-employeer", "")));
                properties.put("managementteam", employee.getProperty("executive", ""));
                properties.put("overtimecompensation", employee.getProperty("overtime-compensation", ""));
                properties.put("ownresultresponsibility", employee.getProperty("own-result-responsibility", ""));
                properties.put("paymentform", employee.getProperty("payment-form", ""));
                properties.put("pensioninsurances", employee.getProperty("pension-insurances", ""));
                properties.put("salary", employee.getProperty("salary", ""));
                properties.put("travelcompensation", employee.getProperty("travel-compensation", ""));
                properties.put("vacationdays", toInt(employee.getProperty("vaication-days", "")));
                properties.put("workhours", employee.getProperty("workhours", ""));

                properties.put("title", oldFunctionNode.getProperty("name", ""));

                properties.put("nodeclass", "employment");

                createNewLink(idMap.get(employee.getId()), createNode(properties), "HAS_EMPLOYMENT");

            }

        }

    }

    public void cloneLanguages() {

        ReturnableEvaluator returnEvaluator = new ReturnableEvaluator() {
            public boolean isReturnableNode(TraversalPosition position) {
                return position.depth() > 2;
            }
        };

        Traverser languageskills = neoIn.getReferenceNode().traverse(Traverser.Order.BREADTH_FIRST,
                StopEvaluator.END_OF_GRAPH, returnEvaluator,
                new SimpleRelationshipType("HAS_ORGANIZATION"), Direction.OUTGOING,
                new SimpleRelationshipType("HAS_EMPLOYEE"), Direction.OUTGOING,
                new SimpleRelationshipType("HAS_LANGUAGESKILL"), Direction.OUTGOING

        );

        for (Node languageskill : languageskills) {

            Relationship employeeRelationship = languageskill.getSingleRelationship(new SimpleRelationshipType("HAS_LANGUAGESKILL"), Direction.INCOMING);

            if (idMap.containsKey(employeeRelationship.getStartNode().getId())) {

                Map<String, Object> properties = new TreeMap<String, Object>();
                addMultipleIfExists(languageskill, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED", "language"}, properties);

                properties.put("written", skillLevel.get(languageskill.getProperty("written", "Viss")));
                properties.put("spoken", skillLevel.get(languageskill.getProperty("spoken", "Viss")));

                properties.put("nodeclass", "languageskill");

                if (properties.containsKey("language")) {
                    idMap.put(languageskill.getId(), createNode(properties));
                    createLink(employeeRelationship);
                }

            }

        }

    }


    public void cloneWorkExperience() {
        ReturnableEvaluator returnEvaluator = new ReturnableEvaluator() {
            public boolean isReturnableNode(TraversalPosition position) {
                return position.depth() > 2;
            }
        };

        Traverser workExperiences = neoIn.getReferenceNode().traverse(Traverser.Order.BREADTH_FIRST,
                StopEvaluator.END_OF_GRAPH, returnEvaluator,
                new SimpleRelationshipType("HAS_ORGANIZATION"), Direction.OUTGOING,
                new SimpleRelationshipType("HAS_EMPLOYEE"), Direction.OUTGOING,
                new SimpleRelationshipType("HAS_WORK_EXPERIENCE"), Direction.OUTGOING);

        for (Node workExperience : workExperiences) {

            Map<String, Object> properties = new TreeMap<String, Object>();
            addMultipleIfExists(workExperience, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED",
                    "name", "company", "trade", "country", "assignment"
            }, properties);


            try {
                properties.put("to", toDate(workExperience.getProperty("to")));
            } catch (Exception e) {
                //no-op
            }
            try {
                properties.put("from", toDate(workExperience.getProperty("from")));
            } catch (Exception e) {
                //no-op
            }

            properties.put("nodeclass", "workexperience");

            if (properties.containsKey("name")) {
                idMap.put(workExperience.getId(), createNode(properties));
            }
            try {
                createLink(workExperience.getSingleRelationship(new SimpleRelationshipType("HAS_WORK_EXPERIENCE"), Direction.INCOMING));
            } catch (Exception e) {
                e.printStackTrace();
            }


        }

    }

    public void cloneCourses() {
        ReturnableEvaluator returnEvaluator = new ReturnableEvaluator() {
            public boolean isReturnableNode(TraversalPosition position) {
                return position.depth() > 2;
            }
        };

        Traverser traverser = neoIn.getReferenceNode().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH,
                returnEvaluator, new SimpleRelationshipType("HAS_ORGANIZATION"), Direction.OUTGOING,
                new SimpleRelationshipType("HAS_EMPLOYEE"), Direction.OUTGOING, new SimpleRelationshipType("HAS_COURSE"),
                Direction.OUTGOING);

        Set<Node> courses = new HashSet<Node>();
        for (Node course : traverser) {
            courses.add(course);
        }

        for (Node course : courses) {
            Relationship employeeRelationship = course.getSingleRelationship(new SimpleRelationshipType("HAS_COURSE"), Direction.INCOMING);
            if (idMap.containsKey(employeeRelationship.getStartNode().getId())) {

                Map<String, Object> properties = new TreeMap<String, Object>();
                addMultipleIfExists(course, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED",
                        "name", "description"}, properties);

                try {
                    properties.put("from", toDate(course.getProperty("from", "")));
                } catch (Exception ex) {
                    //no-op
                }
                try {
                    properties.put("to", toDate(course.getProperty("to", "")));
                } catch (Exception e) {
                    //no-op
                }

                properties.put("nodeclass", "course");

                if (properties.containsKey("name")) {
                    idMap.put(course.getId(), createNode(properties));
                    createLink(employeeRelationship);
                }
            }
        }

    }

    public void cloneEducations() {

        ReturnableEvaluator returnEvaluator = new ReturnableEvaluator() {
            public boolean isReturnableNode(TraversalPosition position) {
                return position.depth() > 2;
            }
        };

        Traverser traverser = neoIn.getReferenceNode().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH,
                returnEvaluator,
                new SimpleRelationshipType("HAS_ORGANIZATION"), Direction.OUTGOING,
                new SimpleRelationshipType("HAS_EMPLOYEE"), Direction.OUTGOING,
                new SimpleRelationshipType("HAS_EDUCATION"), Direction.OUTGOING);

        Set<Node> educations = new HashSet<Node>();
        for (Node education : traverser) {
            educations.add(education);
        }

        for (Node education : educations) {

            Relationship employeeRelationship = education.getSingleRelationship(new SimpleRelationshipType("HAS_EDUCATION"), Direction.INCOMING);

            if (idMap.containsKey(employeeRelationship.getStartNode().getId())) {

                Map<String, Object> properties = new TreeMap<String, Object>();
                addMultipleIfExists(education, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED",
                        "name", "description", "level", "direction", "scope", "country"}, properties);

                try {
                    properties.put("from", toDate(education.getProperty("from", "")));
                } catch (Exception ex) {
                    //no-op
                }
                try {
                    properties.put("to", toDate(education.getProperty("to", "")));
                } catch (Exception e) {
                    //no-op
                }

                properties.put("nodeclass", "education");

                if (properties.containsKey("name")) {
                    idMap.put(education.getId(), createNode(properties));
                    createLink(employeeRelationship);
                }
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
            addMultipleIfExists(unit, new String[]{"UUID", "TS_CREATED", "TS_MODIFIED",
                    "name", "description", "phone", "fax", "email", "web", "address", "postalcode", "city", "country"}, properties);
            idMap.put(unit.getId(), createNode(properties));

            properties.put("nodeclass", "unit");

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
        } catch (Exception e) {
            System.out.println("hello world");
        } finally {
            tx.finish();
        }
    }

    private void createNewLink(long fromId, long toId, String type) {

        Transaction tx = neoOut.beginTx();

        try {

            Node fromNode = neoOut.getNodeById(fromId);

            fromNode.createRelationshipTo(neoOut.getNodeById(toId), new SimpleRelationshipType(type));

            tx.success();

        } finally {
            tx.finish();
            tx = null;
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

    private Integer toInt(Object stringValue) {

        Integer retval = -1;

        try {

            retval = Integer.parseInt((String) stringValue);

        } catch (Exception ex) {
            //no-op
        } finally {
            return retval;
        }

    }

    private Date toDate(Object stringValue) throws Exception {

        Date retval = null;

        retval = dateTool.guessDate((String) stringValue);

        if (retval == null) {
            throw new Exception();
        }

        return retval;

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
        cloner.cloneCourses();
        cloner.createEmployments();
        cloner.cloneLanguages();
        cloner.cloneWorkExperience();
        cloner.cloneEducations();
        cloner.shutdown();

    }

}
