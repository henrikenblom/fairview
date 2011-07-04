package com.fairviewiq.spring.comet;

import org.apache.log4j.Logger;
import org.cometd.Bayeux;
import org.cometd.Client;
import org.cometd.RemoveListener;
import org.mortbay.cometd.BayeuxService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.CopyOnWriteArraySet;

@Component
public class ChatService extends BayeuxService {

    final Logger log = Logger.getLogger(ChatService.class);

    final ConcurrentMap<String, Set<String>> _members = new ConcurrentHashMap<String, Set<String>>();

    @Autowired
    public ChatService(Bayeux bayeux) {
        super(bayeux, "chat");
        subscribe("/chat/**", "trackMembers");
    }

    public void trackMembers(Client joiner, String channel,
                             Map<String, Object> data, String id) {
        if (Boolean.TRUE.equals(data.get("join"))) {
            Set<String> m = _members.get(channel);

            if (m == null) {
                Set<String> new_list = new CopyOnWriteArraySet<String>();
                m = _members.putIfAbsent(channel, new_list);
                if (m == null) {
                    m = new_list;
                }
            }

            final Set<String> members = m;
            final String username = (String) data.get("user");

            members.add(username);

            joiner.addListener(new RemoveListener() {
                public void removed(String clientId, boolean timeout) {
                    members.remove(username);

                    log.info("members: " + members);
                }
            });

            log.info("Members: " + members);

            send(joiner, channel, members, id);
        }
    }

}
