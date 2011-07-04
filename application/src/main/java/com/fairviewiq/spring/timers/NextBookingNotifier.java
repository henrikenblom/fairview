package com.fairviewiq.spring.timers;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import org.apache.log4j.Logger;
import org.apache.lucene.document.DateTools;
import org.apache.lucene.queryParser.ParseException;
import org.neo4j.graphdb.*;
import org.springframework.beans.factory.annotation.Required;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.mail.javamail.MimeMessagePreparator;
import org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer;
import se.codemate.neo4j.NeoSearch;
import se.codemate.neo4j.SimpleRelationshipType;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.mail.internet.MimeMessage;
import java.io.IOException;
import java.io.StringWriter;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.TimerTask;

public class NextBookingNotifier extends TimerTask {

    private static Logger log = Logger.getLogger(NextBookingNotifier.class);

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

    @PostConstruct
    private void init() {
        configuration = freeMarkerConfigurer.getConfiguration();
    }

    public void run() {
        String query = "next_booking_date:[19000101 TO " + DateTools.dateToString(new Date(), DateTools.Resolution.DAY) + "] NOT next_booking_notified:true";
        try {
            Transaction tx = neo.beginTx();
            for (Node node : neoSearch.getNodes(query)) {
                for (Relationship relationship : node.getRelationships(Direction.INCOMING)) {
                    final Node employee = relationship.getOtherNode(node);
                    for (Relationship hasEmployment : employee.getRelationships(new SimpleRelationshipType("HAS_EMPLOYMENT"), Direction.OUTGOING)) {
                        Node employment = hasEmployment.getOtherNode(employee);
                        if (!employment.hasProperty("emp_finish")) {
                            for (Relationship reportsTo : employment.getRelationships(new SimpleRelationshipType("REPORTS_TO"), Direction.OUTGOING)) {
                                final Node manager = reportsTo.getOtherNode(employment);

                                Map<String, Object> model = new HashMap<String, Object>();

                                model.put("neo", neo);
                                model.put("neoSearch", neoSearch);
                                model.put("baseURL",baseURL);

                                model.put("node", node);
                                model.put("employee", employee);
                                model.put("employment", employment);
                                model.put("manager", manager);

                                model.put("type", relationship.getType().name());

                                try {

                                    log.debug("Sending booking reminder to " + manager.getProperty("email"));

                                    Template template = configuration.getTemplate("emails/booking_reminder.ftl");

                                    if (manager.hasProperty("email")) {
                                        final StringWriter writer = new StringWriter();
                                        model.put("target", "manager");
                                        template.process(model, writer);
                                        MimeMessagePreparator preparator = new MimeMessagePreparator() {
                                            public void prepare(MimeMessage mimeMessage) throws Exception {
                                                MimeMessageHelper message = new MimeMessageHelper(mimeMessage);
                                                message.setTo((String) manager.getProperty("email"));
                                                message.setFrom(from);
                                                message.setSubject(subject);
                                                message.setText(writer.toString(), true);
                                            }
                                        };
                                        mailSender.send(preparator);

                                        Node todo = neo.createNode();
                                        todo.setProperty("nodeClass", "todo");
                                        todo.setProperty("date", new Date());
                                        todo.setProperty("content", writer.toString());
                                        manager.createRelationshipTo(todo, new SimpleRelationshipType("HAS_TODO"));

                                    }

                                    if (employee.hasProperty("email")) {
                                        final StringWriter writer = new StringWriter();
                                        model.put("target", "employee");
                                        template.process(model, writer);
                                        MimeMessagePreparator preparator = new MimeMessagePreparator() {
                                            public void prepare(MimeMessage mimeMessage) throws Exception {
                                                MimeMessageHelper message = new MimeMessageHelper(mimeMessage);
                                                message.setTo((String) employee.getProperty("email"));
                                                message.setFrom(from);
                                                message.setSubject(subject);
                                                message.setText(writer.toString(), true);
                                            }
                                        };
                                        mailSender.send(preparator);
                                    }

                                    node.setProperty("next_booking_notified", true);

                                } catch (TemplateException exception) {
                                    log.error("Error while sending mail", exception);
                                }

                            }
                        }
                    }
                }
            }
            tx.success();
            tx.finish();
        } catch (IOException exception) {
            log.error("Error while running search", exception);
        } catch (ParseException exception) {
            log.error("Error while running search", exception);
        }
    }

}
