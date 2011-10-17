package com.fairviewiq.spring.endpoints;

import org.springframework.integration.annotation.MessageEndpoint;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.Message;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessagePreparator;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer;
import org.springframework.beans.factory.annotation.Required;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.index.Term;
import org.apache.log4j.Logger;

import javax.annotation.Resource;
import javax.annotation.PostConstruct;
import javax.mail.internet.MimeMessage;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.io.IOException;
import java.io.StringWriter;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import se.codemate.neo4j.NeoSearch;

public class SignatureEndpoint {

    private static Logger log = Logger.getLogger(SignatureEndpoint.class);

    private String baseURL;
    private String subject;
    private String from;

    @Resource
    private GraphDatabaseService neo;

    @Resource
    private NeoSearch neoSearch;

    @Resource
    private JavaMailSender mailSender;

    @Resource
    private FreeMarkerConfigurer freeMarkerConfigurer;

    private Configuration configuration;

    @PostConstruct
    private void init() {
        configuration = freeMarkerConfigurer.getConfiguration();
    }

    @Required
    public void setBaseURL(String baseURL) {
        this.baseURL = baseURL;
    }

    @Required
    public void setSubject(String subject) {
        this.subject = subject;
    }

    @Required
    public void setFrom(String from) {
        this.from = from;
    }

    @ServiceActivator
    public void handle(Map payload) {

        final Node user = neo.getNodeById((Long) payload.get("userId"));

        if (user.hasProperty("email")) {

            final StringWriter writer = new StringWriter();

            try {

                Map<String, Object> model = new HashMap<String, Object>();

                model.put("neo", neo);
                model.put("signee", user);
                model.put("nodeMap", payload.get("nodeMap"));
                model.put("method", payload.get("method"));
                model.put("baseURL", baseURL);

                if (payload.containsKey("username")) {
                    try {
                        List<Node> nodes = neoSearch.getNodes(new TermQuery(new Term("username", (String) payload.get("username"))));
                        if (nodes.size() == 1) {
                            model.put("modifier", nodes.get(0));
                        }
                    } catch (IOException exception) {
                        log.warn("Error looking up user", exception);
                    }
                }

                Template template = configuration.getTemplate("emails/signature_notification.ftl");
                template.process(model, writer);

                MimeMessagePreparator preparator = new MimeMessagePreparator() {
                    public void prepare(MimeMessage mimeMessage) throws Exception {
                        MimeMessageHelper message = new MimeMessageHelper(mimeMessage);
                        message.setTo((String) user.getProperty("email"));
                        message.setFrom(from);
                        message.setSubject(subject);
                        message.setText(writer.toString(), true);
                    }
                };

                mailSender.send(preparator);

            } catch (IOException exception) {
                log.error("Error while sending mail", exception);
            } catch (TemplateException exception) {
                log.error("Error while sending mail", exception);
            }

        }

    }

}
