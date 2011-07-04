import se.codemate.neo4j.SimpleRelationshipType
import org.neo4j.graphdb.*

neo = new org.neo4j.kernel.EmbeddedGraphDatabase("/opt/neo4j-data/fairview");
tx = neo.beginTx()

employee = neo.getNodeById(137)

Node function = null
int maxPercent = 0;

def returnEvaluator = {
  println("R:"+it.currentNode().getId()+" "+it.currentNode().getProperty("nodeClass", "?"))
  if (it.notStartNode() && it.currentNode().getProperty("nodeClass", null) == "function") {
    int percent = it.lastRelationshipTraversed().getProperty("percent",0)
    if (percent > maxPercent) {
      function = it.currentNode;
      maxPercent = percent;
    }
    return true;
  } else {
    return false;
  }
} as ReturnableEvaluator

def stopEvaluator = {
  println("S:"+it.currentNode().getId()+" "+it.currentNode().getProperty("nodeClass", "?"));
  return it.currentNode().getProperty("emp_finish", null) != null || it.depth() >= 2
} as StopEvaluator

traverser = employee.traverse(
        Traverser.Order.DEPTH_FIRST,
        stopEvaluator,
        returnEvaluator,
        SimpleRelationshipType.withName("HAS_EMPLOYMENT"),
        Direction.OUTGOING,
        SimpleRelationshipType.withName("PERFORMS_FUNCTION"),
        Direction.OUTGOING,
)

functions = traverser.getAllNodes()

println("MAX->"+function);
println("ALL->"+functions);

tx.finish()
neo.shutdown()