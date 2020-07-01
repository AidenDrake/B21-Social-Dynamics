/**
 * "So, I hear you're a real edgelord" -- XKCD #2036
 * 
 * Edges for the model, which represent social connections between agents
 * in a community.
 **/
public HashSet<Edge> edges = new HashSet<Edge>();

public ArrayList<Edge> mfEdges = new ArrayList<Edge>(); // member - former edges
public ArrayList<Edge> mpEdges = new ArrayList<Edge>(); //Member - potential edges

class Edge {
  // Draws and represents an edge between two nodes
  // Graph model should have a big old list of these

  //fields
  Agent a;
  Agent b;
  private boolean highlight = false;

  //Constructor for a "generic edge"
  public Edge(Agent _a, Agent _b) {
    this.a = _a;
    this.b = _b;
  }

  public Edge() {
  } //super constructor

  public void store() {
    boolean hasPotential = a instanceof Potential || b instanceof Potential;
    boolean memberStatus = a instanceof Member || b instanceof Member;
    boolean isFormative = a instanceof Former || b instanceof Former;

    edges.add(this);

    if (isFormative && memberStatus) {
      //MFedge egan = new mfEdge(this.getMember(), this.getPotential())
      // MF_edges.add egan
      // edges.add egan
      mfEdges.add(this);
    }
    if (hasPotential && memberStatus) {
      mpEdges.add(this);
    }
    //else { edges.add(this); }
  }

  public void display() {
    if (this.highlight) {
      strokeWeight(4);
      stroke(125, 0, 0);
    } else {
      strokeWeight(1);
      stroke(125, 125);
    }

    line(a.coord.x, a.coord.y, b.coord.x, b.coord.y);
  }

  public void highlight() {
    this.highlight = true;
  }

  public void unHighlight() {
    this.highlight = true;
  }

  public void recruitPtoM() {
    highlight = true;
  }

  @Override
    public String toString() {
    return("("+this.a+", "+this.b+")");
  }

  @Override
    public boolean equals(Object obj) {
    // returns true if an edge has the same two objects as another
    // this is used for the hashset
    if (!(obj instanceof Edge)) {
      return false;
    }
    Edge e = (Edge) obj; 

    if (this.a.equals(e.a)) {
      return (this.b.equals(e.b));
    } else if (this.a.equals(e.b)) {
      return (this.b.equals(e.a));
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
    return Objects.hash(x, y);
  }

  protected Member getMember() {
    // could be parameterized
    // returns a member if there is one
    // else returns null
    if (a instanceof Member) {
      return (Member) a;
    } else if (b instanceof Member) {
      return (Member) b;
    } else {
      return null;
    }
  }

  protected Potential getPotential() {
    // could be parameterized
    // returns a potential if there is one
    // else returns null
    if (a instanceof Potential) {
      return (Potential) a;
    } else if (b instanceof Potential) {
      return (Potential) b;
    } else {
      return null;
    }
  }

  protected Former getFormer() {
    // could be parameterized
    // returns a former if there is one
    // else returns null
    if (a instanceof Former) {
      return (Former) a;
    } else if (b instanceof Former) {
      return (Former) b;
    } else {
      return null;
    }
  }
}

class MP_Edge extends Edge {
  Member m;
  Potential p;

  MP_Edge(Member m_, Potential p_) {
    super(m_, p_);
    this.p = p_;
    this.m= m_;
  }
}

class MF_Edge extends Edge {
  Member m;
  Former f;

  MF_Edge(Member m_, Former f_) {
    super(m_, f_);
    this.m = m_;
    this.f= f_;
  }
}
