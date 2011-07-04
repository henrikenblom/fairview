/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fairviewiq.dummy;

import java.io.InputStream;
import java.util.HashMap;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 *
 * @author henrik
 */
public class DataImporter {

    public HashMap<Integer, Coworker> fetchDataFromXMLStream(InputStream inputStream, String tagName) {

        HashMap<Integer, Coworker> retval = new HashMap<Integer, Coworker>();

        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

        try {

            Document doc = dbf.newDocumentBuilder().parse(inputStream);
            doc.getDocumentElement().normalize();

            NodeList nodeLst = doc.getElementsByTagName(tagName);

            for (int s = 0; s < nodeLst.getLength(); s++) {

                Node fstNode = nodeLst.item(s);

                Coworker entry = new Coworker();

                if (fstNode.getNodeType() == Node.ELEMENT_NODE) {

                    entry.put("id", getIntegerValue((Element) fstNode, "id"));
                    entry.put("active", getBooleanValue((Element) fstNode, "active"));
                    entry.put("number", getIntegerValue((Element) fstNode, "number"));
                    entry.put("name", getStringValue((Element) fstNode, "name"));
                    entry.put("gender", getStringValue((Element) fstNode, "gender"));
                    entry.put("nationality", getStringValue((Element) fstNode, "nationality"));
                    entry.put("civic", getStringValue((Element) fstNode, "civic"));
                    entry.put("phone", getStringValue((Element) fstNode, "phone"));
                    entry.put("cellphone", getStringValue((Element) fstNode, "cellphone"));
                    entry.put("email", getStringValue((Element) fstNode, "email"));
                    entry.put("salary", getIntegerValue((Element) fstNode, "salary"));
                    entry.put("email", getStringValue((Element) fstNode, "email"));
                    entry.put("salaryRevision", getStringValue((Element) fstNode, "salaryRevision"));

                }

                retval.put((Integer) entry.get("id"), entry);


            }

        } catch (Exception e) {

            e.printStackTrace();

        } finally {

            dbf = null;

            return retval;

        }

    }

    private String getStringValue(Element fstElmnt, String tagName) {

        String retval = new String();

        try {

            NodeList fstNmElmntLst = fstElmnt.getElementsByTagName(tagName);
            Element fstNmElmnt = (Element) fstNmElmntLst.item(0);
            NodeList fstNm = fstNmElmnt.getChildNodes();
            retval = ((Node) fstNm.item(0)).getNodeValue();

        } catch (Exception ex) {

            ex.printStackTrace();

        }

        return retval;

    }

    private Integer getIntegerValue(Element fstElmnt, String tagName) {

        Integer retval = -1;

        try {

            NodeList fstNmElmntLst = fstElmnt.getElementsByTagName(tagName);
            Element fstNmElmnt = (Element) fstNmElmntLst.item(0);
            NodeList fstNm = fstNmElmnt.getChildNodes();
            retval = Integer.parseInt(((Node) fstNm.item(0)).getNodeValue());

        } catch (Exception ex) {

            ex.printStackTrace();

        }

        return retval;

    }

    private Boolean getBooleanValue(Element fstElmnt, String tagName) {

        Boolean retval = false;

        try {

            NodeList fstNmElmntLst = fstElmnt.getElementsByTagName(tagName);
            Element fstNmElmnt = (Element) fstNmElmntLst.item(0);
            NodeList fstNm = fstNmElmnt.getChildNodes();
            retval = Boolean.valueOf(((Node) fstNm.item(0)).getNodeValue());

        } catch (Exception ex) {

            ex.printStackTrace();

        }

        return retval;

    }

}
