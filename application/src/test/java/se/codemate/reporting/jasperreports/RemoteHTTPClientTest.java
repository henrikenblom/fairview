package se.codemate.reporting.jasperreports;

import net.sf.jasperreports.engine.JRException;
import org.apache.lucene.queryParser.ParseException;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import java.io.IOException;

public class RemoteHTTPClientTest {

    RemoteHTTPClient httpClient;

    @BeforeClass(alwaysRun = true)
    public void setUp() throws Exception {
        httpClient = new RemoteHTTPClient("http://fairview.codemate.se:8080", "admin", "secret");
        httpClient.setProxy("localhost:8888");
    }

    @AfterClass(alwaysRun = true)
    public void tearDown() throws Exception {
        httpClient.close();
        System.out.flush();
    }

    @Test(groups = {"functest"})
    public void testGetObject() throws IOException, ParseException, JRException {
        httpClient.getObject("/neo/xml/report-fields.do", "_startNodeID:144 AND _relType:\"HAS_EDUCATION_HIGHER\"");
        httpClient.getObject("/neo/xml/report-fields.do", "_startNodeID:144 AND _relType:\"HAS_EDUCATION_HIGHER\"");
    }

}
