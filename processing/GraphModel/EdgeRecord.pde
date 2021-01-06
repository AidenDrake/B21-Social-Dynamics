public class EdgeRecord {

  //fields
  Agent a, b;
  Edge edge;
  EdgeFactoryImpl factory;

  public EdgeRecord(Agent inputA, Agent inputB) {
    
    this.a = inputA;
    this.b = inputB;

    checkIfNull(a);
    checkIfNull(b);

    factory = new EdgeFactoryImpl(this);
    this.edge = factory.makeEdge();
  }

  private void checkIfNull(Agent agent) throws NullPointerException {
    if (agent == null) {
      throw new NullPointerException();
    }
  }

  public Agent getType(AgentType t) {
    //Note : for t-t edges, this will always return a
    if (a.isType(t)) {
      return a;
    } else if (b.isType(t)) {
      return b;
    } else {
      return null; // yikes
    }
  }

  public Agent getA() {
    return this.a;
  }

  public Agent getB() {
    return this.b;
  }
  
  public void remakeEdge(){
    this.edge = factory.makeEdge();
  }

  @Override
    public boolean equals(Object obj) {
    // returns true if an edge has the same two objects as another
    // this is used for the hashset
    if (!(obj instanceof Edge)) {
      return false;
    }
    EdgeRecord er = (EdgeRecord) obj; 

    if (this.a.equals(er.a)) {
      return (this.b.equals(er.b));
    } else if (this.a.equals(er.b)) {
      return (this.b.equals(er.a));
    }
    return false;
  }
  
  @Override
  public String toString(){
    return ("<" + a +", " + b + ">");
  }

  @Override
    public int hashCode() {
    Agent x;
    Agent y;
    if (a.getIndex()<b.getIndex()) {
      x = a;
      y = b;
    } else {
      x = b;
      y = a;
    }
    return Objects.hash(x, y, "EdgeRecord");
  }
}

public class EdgeRecordStorage implements Iterable<EdgeRecord> {
  // object is meant to be an abstraction from the data structures it contains
  private HashMap<Agent, LinkedList<EdgeRecord>> structure;
  private HashSet<EdgeRecord> hashset = new HashSet<EdgeRecord>();

  public EdgeRecordStorage(HashSet<Agent> agents) {
    structure = new HashMap<Agent, LinkedList<EdgeRecord>>();
    for (Agent agent : agents){
      structure.put(agent, new LinkedList<EdgeRecord>());
    }
  }
  
  public Iterator<EdgeRecord> iterator(){
    return this.hashset.iterator();
  }

  public void store (EdgeRecord er) {
    hashset.add(er);

    Agent a = er.getA();
    Agent b = er.getB();

    structure.get(a).add(er);
    structure.get(b).add(er);
  }

  public boolean hasStored(EdgeRecord ertest) {
    boolean out = hashset.contains(ertest);
    return out;
  }

  public void newRandEdgeRecord() {
    // the j<20 might be a problem with extremely dense edges, but I don't know how to handle it
    int j = 0;
    EdgeRecord er = null;
    while (((this.hasStored(er)) && j<20) || er == null ) { // avoid duplicate edges
      // j is a dumb hack to avoid an infinite loop
      Agent firstVertex = randomAgent();
      Agent secondVertex = randomAgent();
      while (firstVertex.equals(secondVertex)) { // if we pick one that's the same, pick again
        secondVertex = randomAgent();
      }
      er = new EdgeRecord(firstVertex, secondVertex);
      j ++;
    }
    store(er);
  }

  @Override 
    String toString() {
    return (this.structure.toString());
  }
}
