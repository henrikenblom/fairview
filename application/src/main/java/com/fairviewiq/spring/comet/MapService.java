package com.fairviewiq.spring.comet;

import org.cometd.Bayeux;
import org.cometd.Client;
import org.cometd.Message;
import org.mortbay.cometd.BayeuxService;
import org.mortbay.log.Log;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.integration.annotation.MessageEndpoint;

import java.util.HashMap;
import java.util.Map;

@MessageEndpoint
public class MapService extends BayeuxService {

    private final Map<String, Client> seenClients = new HashMap<String, Client>();

    private final GeoPoint points = new GeoPoint();

    @Autowired
    public MapService(Bayeux bayeux) {
        super(bayeux, "chat");
        subscribe("/map/newpoint", "newPoint");
        subscribe("/meta/subscribe", "subscribeMon");
    }

    public void subscribeMon(Client joiner, Message message) {

        String channelName = message.get("subscription").toString();

        String messageId = message.get("id").toString();

        // if a client is subscribing to the newpoint channel we want to send old points
        if (channelName.equals("/map/newpoint")) {
            Client client = seenClients.get(joiner.getId());
            // if the client has not been seen before (new) send them the list.
            if (client == null) {
                seenClients.put(joiner.getId(), joiner);
                // but only if there are points, otherwise this is probably the first client
                if (points.length > 0)
                    joiner.deliver(getClient(), channelName, points.getPoints(), messageId);
            }
        }

    }

    public void newPoint(final Client joiner, final String channelName, Map<String, Object> data, final String messageId) {
        // pretty basic what is going on here.
        // if there is lat and lng fields in the data, add them to the list
        if ((data.get("lat") != null) && (data.get("lng") != null)) {
            Log.info("New point: [" + data.get("lat") + "," + data.get("lng") + "] " + data.get("msg"));
            // GeoPoints points holds all the marker points for later retreival
            points.addPoint(data.get("lat"), data.get("lng"), data.get("msg"));
        }
    }

    /*
    http://localhost:8080/integration.do?latitude=59.22093407615045&longitude=17.2265625&message=hello
     */

}

