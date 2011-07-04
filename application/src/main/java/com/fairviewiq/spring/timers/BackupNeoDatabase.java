package com.fairviewiq.spring.timers;

import org.neo4j.kernel.EmbeddedGraphDatabase;
import se.codemate.spring.mvc.ModelMapConverter;
import com.thoughtworks.xstream.XStream;
import org.apache.log4j.Logger;
import org.neo4j.graphdb.*;
import org.springframework.beans.factory.annotation.Required;
import org.springframework.ui.ModelMap;
import se.codemate.neo4j.MapPropertyContainer;
import se.codemate.neo4j.XStreamXMLMapPropertyContainerConverter;
import se.codemate.neo4j.XStreamXMLNodeConverter;
import se.codemate.neo4j.XStreamXMLRelationshipConverter;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

public class BackupNeoDatabase extends TimerTask {

    private static Logger log = Logger.getLogger(BackupNeoDatabase.class);
    private static SimpleDateFormat dateFormat = new SimpleDateFormat("'_'yyMMddHHmmss'.xml'");

    @Resource
    private EmbeddedGraphDatabase neo;

    private String locationXML;

    private String locationMirror;

    private XStream xstream;

    @Required
    public void setLocationXML(String locationXML) {
        this.locationXML = locationXML;
    }

    public void setLocationMirror(String locationMirror) {
        this.locationMirror = locationMirror;
    }

    @PostConstruct
    private void init() {

        xstream = new XStream();

        xstream.setMode(XStream.NO_REFERENCES);

        xstream.registerConverter(new ModelMapConverter(xstream.getMapper()), XStream.PRIORITY_VERY_HIGH);
        xstream.registerConverter(new XStreamXMLNodeConverter(neo, xstream.getMapper()));
        xstream.registerConverter(new XStreamXMLRelationshipConverter(neo, xstream.getMapper()));
        xstream.registerConverter(new XStreamXMLMapPropertyContainerConverter(xstream.getMapper()));

        xstream.alias("model", ModelMap.class);
        xstream.alias("node", Node.class);
        xstream.alias("relationship", Relationship.class);
        xstream.alias("mapPropertyContainer", MapPropertyContainer.class);

        try {
            xstream.alias("node", Class.forName("org.neo4j.impl.core.NodeImpl"));
            xstream.alias("node", Class.forName("org.neo4j.impl.core.NodeProxy"));
        } catch (ClassNotFoundException e) {
            // no-op
        }

        try {
            xstream.alias("relationship", Class.forName("org.neo4j.impl.core.RelationshipImpl"));
            xstream.alias("relationship", Class.forName("org.neo4j.impl.core.RelationshipProxy"));
        } catch (ClassNotFoundException e) {
            // no-op
        }

    }

    public void run() {

        Node node = neo.getReferenceNode();

        LinkedList<Node> queue = new LinkedList<Node>();
        queue.add(node);

        Set<Node> nodes = new HashSet<Node>();
        Set<Relationship> relationships = new HashSet<Relationship>();

        Transaction tx = neo.beginTx();

        while (!queue.isEmpty()) {
            Node currentNode = queue.removeFirst();
            if (nodes.add(currentNode)) {
                for (Relationship relationship : currentNode.getRelationships(Direction.OUTGOING)) {
                    if (relationships.add(relationship)) {
                        queue.add(relationship.getEndNode());
                    }
                }
            }
        }

        try {
            File file = new File(this.locationXML + dateFormat.format(new Date()));
            BufferedWriter writer = new BufferedWriter(new FileWriter(file));
            xstream.toXML(nodes, writer);
            xstream.toXML(relationships, writer);
            writer.close();
        } catch (IOException exception) {
            log.error("Error while doing backup to XML format", exception);
        } finally {
            tx.success();
            tx.finish();
        }

/* EXPERIMENTAL - Disabled for now
        if (locationMirror != null) {
            Backup backupComp = new NeoBackup(neo, locationMirror);
            try {
                backupComp.doBackup();
            } catch (IOException exception) {
                log.error("Error while doing backup to mirror", exception);
            }
        }
*/

    }

}
