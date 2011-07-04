import se.codemate.neo4j.SimpleRelationshipType
import org.neo4j.graphdb.*

neo = new org.neo4j.kernel.EmbeddedGraphDatabase("/opt/neo4j-data/fairview-debug");
tx = neo.beginTx()

employee = neo.getNodeById(11)

negotiations = employee.traverse(
        Traverser.Order.DEPTH_FIRST,
        StopEvaluator.DEPTH_ONE,
        ReturnableEvaluator.ALL_BUT_START_NODE,
        SimpleRelationshipType.withName("HAS_SALARY_NEGOTIATION"),
        Direction.OUTGOING,
).getAllNodes()

Date now = new Date();
long max = 0;

int salary = -1;

for (negotiation in negotiations) {
  if (negotiation.hasProperty("salary_activation_date")) {
    Date activationDate = (Date) negotiation.getProperty("salary_activation_date")
    if (now.compareTo(activationDate) >= 0 ) {
      if (activationDate.getTime() > max) {
        salary = (Integer) negotiation.getProperty("salary_after_raise",0);
        max = activationDate.getTime();
      }
    }
    println(now+" "+activationDate+" "+salary+now.compareTo(activationDate));
  }
}

tx.finish()
neo.shutdown()