package com.fairviewiq.spring.freemarker;

import freemarker.core.Environment;
import freemarker.template.TemplateDirectiveBody;
import freemarker.template.TemplateDirectiveModel;
import freemarker.template.TemplateException;
import freemarker.template.TemplateModel;
import freemarker.ext.beans.BeanModel;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.apache.lucene.queryParser.ParseException;
import se.codemate.neo4j.NeoSearch;

public class DynamicOptionsDirective implements TemplateDirectiveModel {

    public void execute(Environment env, Map params, TemplateModel[] loopVars, TemplateDirectiveBody body) throws TemplateException, IOException {

        String nodeClass = params.containsKey("class") ? params.get("class").toString() : "";
        String propertyKey = params.containsKey("property") ? params.get("property").toString() : "";
        String selected = params.containsKey("selected") ? params.get("selected").toString() : "";

        NeoSearch neoSearch = (NeoSearch) ((BeanModel) env.getVariable("neoSearch")).getWrappedObject();

        Set<String> options = new TreeSet<String>();

        try {
            for (Node node : neoSearch.getNodes("nodeClass:" + nodeClass)) {
                if (node.hasProperty(propertyKey)) {
                    options.add((String) node.getProperty(propertyKey));
                }
            }
        } catch (ParseException exception) {
            // NO-OP
        }

        PrintWriter printWriter = new PrintWriter(env.getOut());

        for (String option : options) {
            if (selected.equalsIgnoreCase(option)) {
                printWriter.println("<option value=\"" + option + "\" selected=\"true\">" + option + "</option>");
            } else {
                printWriter.println("<option value=\"" + option + "\">" + option + "</option>");
            }
        }

    }

}

