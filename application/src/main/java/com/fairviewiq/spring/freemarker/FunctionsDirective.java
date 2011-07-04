package com.fairviewiq.spring.freemarker;

import freemarker.core.Environment;
import freemarker.template.TemplateDirectiveBody;
import freemarker.template.TemplateDirectiveModel;
import freemarker.template.TemplateException;
import freemarker.template.TemplateModel;
import org.neo4j.graphdb.*;
import se.codemate.neo4j.SimpleRelationshipType;
import se.codemate.spring.freemarker.NeoNodeModel;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import java.util.Collection;
import java.util.Iterator;

public class FunctionsDirective implements TemplateDirectiveModel {

    public void execute(Environment env, Map params, TemplateModel[] loopVars, TemplateDirectiveBody body) throws TemplateException, IOException {

        NeoNodeModel employee = (NeoNodeModel) params.get("employee");

        String prefix = params.containsKey("prefix") ? params.get("prefix").toString() : "";
        String suffix = params.containsKey("suffix") ? params.get("suffix").toString() : "";
        String separator = params.containsKey("separator") ? params.get("separator").toString() : ", ";
        String blank = params.containsKey("blank") ? params.get("blank").toString() : "";

        Traverser functionsTraverser = ((Node) employee.getWrappedObject()).traverse(
                Traverser.Order.DEPTH_FIRST,
                StopEvaluator.END_OF_GRAPH,
                new ReturnableEvaluator() {
                    public boolean isReturnableNode(TraversalPosition traversalPosition) {
                        return traversalPosition.currentNode().hasProperty("nodeClass") &&
                                "function".equals(traversalPosition.currentNode().getProperty("nodeClass")) &&
                                traversalPosition.currentNode().hasProperty("name");

                    }
                },
                SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.OUTGOING,
                SimpleRelationshipType.withName("PERFORMS_FUNCTION"), Direction.OUTGOING
        );

        PrintWriter printWriter = new PrintWriter(env.getOut());

        Collection<Node> functions = functionsTraverser.getAllNodes();
        if (functions.size() > 0) {
            printWriter.print(prefix);
            Iterator iterator = functions.iterator();
            while (iterator.hasNext()) {
                Node function = (Node) iterator.next();
                String name = function.getProperty("name", "").toString().trim();
                if (name.length() > 0) {
                    printWriter.print(name);
                    if (iterator.hasNext()) {
                        printWriter.print(separator);
                    }
                }
            }
            printWriter.print(suffix);
        } else {
            printWriter.print(blank);
        }

    }

}

