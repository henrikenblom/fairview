package com.fairviewiq.spring.timers;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import org.apache.log4j.Logger;
import org.neo4j.graphdb.*;
import org.springframework.beans.factory.annotation.Required;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessagePreparator;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer;
import se.codemate.neo4j.NeoSearch;
import se.codemate.neo4j.SimpleRelationshipType;
import se.codemate.neo4j.NeoUtils;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.mail.internet.MimeMessage;
import java.util.*;
import java.io.StringWriter;

public class CVCompletionNotifier extends TimerTask {

    private static Logger log = Logger.getLogger(CVCompletionNotifier.class);

    private Map<String, Integer> completionProfile;
    private int completionTotal;

    private String baseURL;
    private String subject;
    private String from;
    private int bossTrigger = 3;
    private long notificationInterval = 1000 * 60 * 60 * 24 * 7; // Millis/week

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
    public void setCompletionProfile(Map<String, Integer> completionProfile) {
        this.completionProfile = completionProfile;
        for (Integer integer : completionProfile.values()) {
            completionTotal += integer;
        }
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

    public void setBossTrigger(int bossTrigger) {
        this.bossTrigger = bossTrigger;
    }

    public void setNotificationIntervalMinutes(long notificationInterval) {
        this.notificationInterval = 1000 * 60 * notificationInterval; // Convert minutes to millis.
    }

    @PostConstruct
    private void init() {
        configuration = freeMarkerConfigurer.getConfiguration();
    }

    public void run() {
        try {
            Transaction tx = neo.beginTx();

            Traverser traverser = neo.getReferenceNode().traverse(
                    Traverser.Order.DEPTH_FIRST,
                    StopEvaluator.END_OF_GRAPH,
                    new ReturnableEvaluator() {
                        public boolean isReturnableNode(TraversalPosition traversalPosition) {
                            return "employee".equals(traversalPosition.currentNode().getProperty("nodeClass", null));
                        }
                    },
                    SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING,
                    SimpleRelationshipType.withName("HAS_EMPLOYEE"), Direction.OUTGOING
            );

            for (Node node : traverser) {

                if (node.hasProperty("email")) {

                    Map<String, Integer> profile = new TreeMap<String, Integer>();
                    for (Relationship relationship : node.getRelationships(Direction.OUTGOING)) {
                        String key = relationship.getType().toString();
                        profile.put(key, profile.containsKey(key) ? profile.get(key) + 1 : 1);
                    }

                    boolean isComplete = true;
                    int profileTotal = 0;
                    for (String key : completionProfile.keySet()) {
                        int c = profile.containsKey(key) ? profile.get(key) : 0;
                        profileTotal += Math.min(completionProfile.get(key), c);
                        if (c < completionProfile.get(key)) {
                            isComplete = false;
                        }
                    }

                    if (!isComplete) {

                        long lastNotificationTime = (Long) node.getProperty("cv_notification_timestamp", 0l);

                        if (System.currentTimeMillis() - lastNotificationTime > notificationInterval) {

                            final int notifications = (Integer) node.getProperty("cv_notification_count", 1);

                            final Map<String, Object> model = new HashMap<String, Object>();
                            model.put("neo", neo);
                            model.put("neoSearch", neoSearch);
                            model.put("employee", node);
                            model.put("progress", completionTotal == 0 ? 0 : (100 * profileTotal) / completionTotal);
                            model.put("notification", notifications);
                            model.put("baseURL",baseURL);

                            if (notifications >= bossTrigger) {
                                Traverser bossTraverser = node.traverse(
                                        Traverser.Order.DEPTH_FIRST,
                                        new StopEvaluator() {
                                            public boolean isStopNode(TraversalPosition traversalPosition) {
                                                return traversalPosition.currentNode().getProperty("emp_finish", null) != null || traversalPosition.depth() >= 2;
                                            }
                                        },
                                        new ReturnableEvaluator() {
                                            public boolean isReturnableNode(TraversalPosition traversalPosition) {
                                                return !traversalPosition.isStartNode() && "employee".equals(traversalPosition.currentNode().getProperty("nodeClass", null));
                                            }
                                        },
                                        SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.OUTGOING,
                                        SimpleRelationshipType.withName("REPORTS_TO"), Direction.OUTGOING
                                );
                                List<Node> bossList = NeoUtils.toNodeList(bossTraverser.getAllNodes());
                                if (bossList.size() == 1) {
                                    model.put("reportsTo", bossList.get(0));
                                }
                            }

                            final String to = (String) node.getProperty("email");
                            final StringWriter writer = new StringWriter();

                            try {

                                log.debug("Sending CV reminder #" + notifications + " to " + node.getProperty("email"));

                                Template template = configuration.getTemplate("emails/cv_reminder.ftl");
                                template.process(model, writer);

                                MimeMessagePreparator preparator = new MimeMessagePreparator() {
                                    public void prepare(MimeMessage mimeMessage) throws Exception {
                                        MimeMessageHelper message = new MimeMessageHelper(mimeMessage);
                                        message.setTo(to);
                                        if (model.containsKey("reportsTo")) {
                                            Node boss = (Node) model.get("reportsTo");
                                            if (boss.hasProperty("email")) {
                                                log.debug("CC:ing CV reminder #" + notifications + " to " + boss.getProperty("email"));
                                                message.setCc((String) boss.getProperty("email"));
                                            }
                                        }
                                        message.setFrom(from);
                                        message.setSubject(subject);
                                        message.setText(writer.toString(), true);
                                    }
                                };

                                mailSender.send(preparator);

                                node.setProperty("cv_notification_timestamp", System.currentTimeMillis());
                                node.setProperty("cv_notification_count", notifications + 1);

                            } catch (TemplateException exception) {
                                log.error("Error while sending mail", exception);
                            }

                        }
                    } else {
                        if (node.hasProperty("cv_notification_count")) {
                            node.removeProperty("cv_notification_count");
                        }
                    }
                }
            }

            tx.success();
            tx.finish();

        } catch (Exception exception) {
            log.error("Error while running search", exception);
        }

    }

}

