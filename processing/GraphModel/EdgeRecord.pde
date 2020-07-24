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

public class EdgeRecordStorage {
  ArrayList<LinkedList<EdgeRecord>> structure; // should also be a hashmap
  HashSet<EdgeRecord> hashset = new HashSet<EdgeRecord>();

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
    hashset.add(er);
    
    Agent a = er.getA();
    Agent b = er.getB();

    int aIndex = a.getIndex();
    int bIndex = b.getIndex();

    structure.get(aIndex).add(er);
    structure.get(bIndex).add(er);
  }
  
  public boolean isStored(EdgeRecord ertest) {
    boolean out = hashset.contains(ertest);
    return out;
  }
  
  public void newRandEdgeRecord() {
    
  }

  @Override 
    String toString() {
    return (this.structure.toString());
  }
}
