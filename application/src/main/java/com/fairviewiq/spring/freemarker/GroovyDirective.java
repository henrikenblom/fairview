package com.fairviewiq.spring.freemarker;

import freemarker.core.Environment;
import freemarker.ext.beans.BeanModel;
import freemarker.template.*;
import groovy.lang.Binding;
import groovy.lang.GroovyShell;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Map;

/**
 * <p>FreeMarker user-defined directive for executing a goovy script</p>
 * <p><b>Directive info</b></p>
 * <p>Parameters:
 * <ul>
 * <li><code>bind</code>: Variable name to bind script results too
 * </ul>
 * <p/>
 * <p>Nested content: Yes</p>
 */
public class GroovyDirective implements TemplateDirectiveModel {

    private static final String PARAM_NAME_BIND = "bind";

    public void execute(Environment env, Map params, TemplateModel[] loopVars, TemplateDirectiveBody body) throws TemplateException, IOException {

        if (loopVars.length != 0) {
            throw new TemplateModelException("This directive doesn't allow loop variables.");
        }

        if (body != null) {

            StringWriter writer = new StringWriter();
            body.render(writer);
            String groovy = writer.toString();

            Binding binding = new Binding();
            for (Object name : env.getKnownVariableNames()) {
                TemplateModel variable = env.getVariable(name.toString());
                if (BeanModel.class.isInstance(variable)) {
                    binding.setVariable(name.toString(), ((BeanModel) variable).getWrappedObject());
                }
            }
            binding.setVariable("out", new PrintWriter(env.getOut()));

            GroovyShell groovyShell = new GroovyShell(binding);

            Object result = groovyShell.evaluate(groovy);
            if (result != null) {
                Object name = params.get(PARAM_NAME_BIND);
                if (name == null) {
                    env.getOut().write(result.toString());
                } else {
                    env.setVariable(name.toString(), env.getObjectWrapper().wrap(result));
                }
            }

        } else {
            throw new RuntimeException("missing body");
        }

    }

}
