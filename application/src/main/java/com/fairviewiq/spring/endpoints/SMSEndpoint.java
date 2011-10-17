package com.fairviewiq.spring.endpoints;

import org.apache.log4j.Logger;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Transaction;
import org.springframework.integration.annotation.MessageEndpoint;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.Message;
import org.springframework.integration.support.MessageBuilder;
import se.codemate.neo4j.NeoSearch;
import se.codemate.neo4j.SimpleRelationshipType;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;
import java.util.Map;

@MessageEndpoint
public class SMSEndpoint {

    private static Logger log = Logger.getLogger(SMSEndpoint.class);

    @Resource
    private NeoSearch neoSearch;

    @Resource
    private GraphDatabaseService neo;

    @ServiceActivator(inputChannel = "smsChannel", outputChannel = "absenceChannel")
    public Message handle(Map payload) {

        /*

        message Innehåller meddelandets innehåll.
        number Numret meddelandet inkom till.
        operator Avsändarens operatörsnamn. Möjliga värden är TELE2, TRE, TELIA, TELENOR, BOZOKA (BOZOKA är ingen riktig teleoperatör utan används bara vid testning).
        msisdn Avsändarens telefonnummer.
        timestamp Anger tidpunkten då meddelandet skickades. Tidpunkten är angiven i antalet millisekunder som har passerat sedan den 1:a januari 1970 UTC.
        ordertext Beställningstexten som inkommet meddelande matchade
        priceamount Det pris kunden betalade, till exempel 5.00.
        pricecurrency Prisets valutakod, till exempel SEK för svenska kronor.
        longitude Longituden för den positionerade telefonen, uttryckt som ett decimaltal
        latitude Latituden för den positionerade telefonen, uttryckt som ett decimaltal
        accuracy Noggranheten för positioneringen i meter
        pos_ts Tidpunkten då positioneringen utfördes. Tidpunkten är angiven i antalet millisekunder som har passerat sedan den 1:a januari 1970 UTC.

        http://localhost:8080/sms.do?latitude=59.22093407615045&longitude=17.2265625&ordertext=tag%20fv&message=tag%20fv%20sjuk&msisdn=46733210221

        */

        log.debug("Inbound SMS: " + payload);

        try {

            String query = "cell:"+payload.get("msisdn")+" OR cell_private:"+payload.get("msisdn");
            List<Node> nodes = neoSearch.getNodes(query);
            if (nodes.size() == 1) {

                Transaction tx = neo.beginTx();

                Node node = neo.createNode();

                String message = (String) payload.get("message");
                if (message != null && message.trim().toLowerCase().startsWith("tag ")) {
                    message = message.trim().substring(4);
                }

                node.setProperty("nodeClass", "absence");
                node.setProperty("start", new Date());
                node.setProperty("reason", message);

                if (payload.containsKey("longitude") && payload.containsKey("latitude")) {
                    node.setProperty("longitude", Double.parseDouble(payload.get("longitude").toString()));
                    node.setProperty("latitude", Double.parseDouble(payload.get("latitude").toString()));
                }

                nodes.get(0).createRelationshipTo(node, new SimpleRelationshipType("HAS_ABSENCE"));

                MessageBuilder messageBuilder = MessageBuilder.withPayload(node.getId());

                tx.success();
                tx.finish();

                return messageBuilder.build();

            }
        } catch (Exception exception) {
            log.error("Error processing SMS", exception);
        }

        return null;

    }

}
