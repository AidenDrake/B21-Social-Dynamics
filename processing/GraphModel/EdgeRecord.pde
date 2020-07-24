public class EdgeRecord {

  //fields
  Agent a, b;
  Edge edge;

  public EdgeRecord(Agent inputA, Agent inputB) {
    this.a = inputA;
    this.b = inputB;

    EdgeFactoryImpl factory = new EdgeFactoryImpl(this);
    this.edge = factory.makeEdge();
  }

  public Member getMember() {
    if (a instanceof Member) {
      return (Member) a;
    } else if (b instanceof Member) {
      return (Member) b;
    } else {
      return null;
    }
  }

  public Potential getPotential() {
    if (a instanceof Potential) {
      return (Potential) a;
    } else if (b instanceof Potential) {
      return (Potential) b;
    } else {
      return null;
    }
  }

  public Former getFormer() {
    if (a instanceof Former) {
      return (Former) a;
    } else if (b instanceof Former) {
      return (Former) b;
    } else {
      return null;
    }
  }

  public Agent getA() {
    return this.a;
  }

  public Agent getB() {
    return this.b;
  }
}

public class EdgeRecordStorage {
  ArrayList<LinkedList<EdgeRecord>> structure;

  public EdgeRecordStorage(HashSet<Agent> agents, HashSet<EdgeRecord> edgeRecords) {
    structure = new ArrayList<LinkedList<EdgeRecord>>();
    structure.add(null); // for 0, which does not correspond to an agent index
    for (int i = 1; i < agents.size(); i++) {
      //setup
      structure.add(new LinkedList<EdgeRecord>());
    }
    for (EdgeRecord er : edgeRecords) {
      store(er);
    }
  }

  public void store (EdgeRecord er) {
    Agent a = er.getA();
    Agent b = er.getB();

    int aIndex = a.getIndex();
    int bIndex = b.getIndex();

    structure.get(aIndex).add(er);
    structure.get(bIndex).add(er);
  }

  @Override 
    String toString() {
    return (this.structure.toString());
  }
}
