package com.fairviewiq.spring.aspects;

import org.springframework.beans.factory.annotation.Configurable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.integration.core.MessageChannel;
import org.springframework.integration.message.MessageBuilder;
import org.springframework.integration.channel.MessageChannelTemplate;
import org.springframework.context.ApplicationContext;
import org.springframework.security.context.SecurityContext;
import org.springframework.security.context.SecurityContextImpl;
import org.springframework.security.context.SecurityContextHolder;
import org.springframework.security.userdetails.User;
import org.springframework.security.Authentication;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.ProceedingJoinPoint;
import org.apache.log4j.Logger;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Direction;
import org.neo4j.graphdb.Relationship;

import java.io.IOException;
import java.util.Set;
import java.util.Map;
import java.util.HashMap;
import java.security.Principal;

import se.codemate.neo4j.SimpleRelationshipType;
import se.codemate.neo4j.NeoUtils;

@Configurable
@Aspect
public class SignatureNotificationAspect {

    private static Logger log = Logger.getLogger(SignatureNotificationAspect.class);

    @Autowired
    private ApplicationContext applicationContext;

    private MessageChannelTemplate template = new MessageChannelTemplate();

    private MessageChannel messageChannel;

    @Around(value = "execution(* se.codemate.neo4j.NeoUtils.deleteNode(..))")
    public Object removeProperty(ProceedingJoinPoint pjp) throws Throwable {
        if (log.isDebugEnabled()) {
            log.debug("Node to be deleted, notifying signees");
        }
        Object[] args = pjp.getArgs();
        if (args != null && args.length == 1) {
            resetSignatures((Node) args[0], "delete");
        }
        return pjp.proceed();
    }

    @AfterReturning(value = "execution(* org.neo4j.graphdb.Node.setProperty(..)) && target(node)", argNames = "node")
    public void nodeSetProperty(Node node) {
        if (log.isDebugEnabled()) {
            log.debug("Node property set, notifying signees");
        }
        resetSignatures(node, "update");
    }

    @AfterReturning(value = "execution(* org.neo4j.graphdb.Node.removeProperty(..)) && target(node)", argNames = "node")
    public void nodeRemoveProperty(Node node) {
        if (log.isDebugEnabled()) {
            log.debug("Node property removed, notifying signees");
        }
        resetSignatures(node, "update");
    }

    private void resetSignatures(Node node, String method) {

        if (messageChannel == null) {
            messageChannel = (MessageChannel) applicationContext.getBean("signatureChannel");
            template.setDefaultChannel(messageChannel);
        }
        if (node.hasProperty("nodeClass")) {
            for (Relationship relationship : node.getRelationships(new SimpleRelationshipType("SIGNATURE"), Direction.INCOMING)) {
                Map<String, Object> map = new HashMap<String, Object>();
                map.put("userId", relationship.getStartNode().getId());
                map.put("method", method);
                Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
                if (authentication != null) {
                    User user = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
                    if (user != null) {
                        map.put("username", user.getUsername());
                    }
                }
                Map<String, Object> nodeMap = new HashMap<String, Object>();
                for (String key : relationship.getEndNode().getPropertyKeys()) {
                    nodeMap.put(key, relationship.getEndNode().getProperty(key, null));
                }
                nodeMap.put("id", node.getId());
                map.put("nodeMap", nodeMap);
                MessageBuilder messageBuilder = MessageBuilder.withPayload(map);
                template.send(messageBuilder.build());
                relationship.delete();
            }
        }
    }

}
