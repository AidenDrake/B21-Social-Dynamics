/** //<>// //<>// //<>//
 * "So, I hear you're a real edgelord" -- XKCD #2036
 * 
 * Edges for the model, which represent social connections between agents
 * in a community.
 **/
public HashSet<Edge> drawnEdges = new HashSet<Edge>();

public HashSet<MemberFormerEdge> mfEdges = new HashSet<MemberFormerEdge>(); // member - former edges
public HashSet<MemberPotentialEdge> mpEdges = new HashSet<MemberPotentialEdge>(); //Member - potential edges

class Edge {
  // Draws and represents an edge between two nodes
  // Graph model should have a big old list of these

  //fields
  Agent a;
  Agent b;
  boolean highlight = false;

  //Constructor for a "generic edge"
  public Edge(EdgeRecord er) {
    this.a = er.getA();
    this.b = er.getB();
  }
  
  //protected because don't want outside classes to make edges in this
  // "data structure" way
  protected Edge(Agent _a, Agent _b) {
    this.a = _a;
    this.b = _b;
    drawnEdges.add(this);
  }
  
  public Edge() {
  } //super constructor
  
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
    this.highlight = false;
  }

  @Override
    public String toString() {
    return("(" + this.getClass().getName()+": "+this.a+", "+this.b+")");
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
    return Objects.hash(x, y, "Edge");
  }
}

class MemberPotentialEdge extends Edge {
  Agent memberInstance;
  Agent potentialInstance;

  MemberPotentialEdge(Agent m_, Agent p_) {
    super(m_, p_);
    this.potentialInstance = p_;
    this.memberInstance = m_;
    mpEdges.add(this);
  }

  public void recruitPtoM() {
    // test test test -- I doubt this will work at ALLL now 
    drawnEdges.remove(this);
    mpEdges.remove(this);
    
    this.potentialInstance.toType(member);
    Agent newMem = this.potentialInstance;
    Edge ne = new Edge(newMem, this.memberInstance); // ne -> new edge
    ne.a.setPuller(this.memberInstance, ne);
    ne.highlight();
    activeCount++; 
    active.add(this);
  }

  public void display() {
    if (this.highlight) {
      strokeWeight(4);
      stroke(0, 125, 0);
    } else {
      strokeWeight(2);
      stroke(0, 0, 255); //Blue
    }

    line(a.coord.x, a.coord.y, b.coord.x, b.coord.y);
  }
}

class MemberFormerEdge extends Edge {
  Agent memberInstance;
  Agent formerInstance;

   MemberFormerEdge(Agent m_, Agent f_) {
    super(m_, f_);
    this.memberInstance = m_;
    this.formerInstance = f_;
    mfEdges.add(this);
  }
  
   public void recruitMtoF() {
    // test test test
    drawnEdges.remove(this);
    mfEdges.remove(this);
    
    this.memberInstance.toType(former);
    Agent newFormer = this.memberInstance;
    
    Edge ne = new Edge(newFormer, this.formerInstance);
    ne.a.setPuller(this.formerInstance, ne);
    ne.highlight();
    activeCount++; 
    active.add(this);
  }
  
    public void display() {
    if (this.highlight) {
      strokeWeight(4);
      stroke(0, 125, 0);
    } else {
      strokeWeight(2);
      stroke(0, 255, 0); //Green
    }

    line(a.coord.x, a.coord.y, b.coord.x, b.coord.y);
  }
}
