/** //<>//
 * "So, I hear you're a real edgelord" -- XKCD #2036
 * 
 * Edges for the model, which represent social connections between agents
 * in a community.
 **/
public HashSet<Edge> edges = new HashSet<Edge>();

public HashSet<MemberFormerEdge> mfEdges = new HashSet<MemberFormerEdge>(); // member - former edges
public HashSet<MemberPotentialEdge> mpEdges = new HashSet<MemberPotentialEdge>(); //Member - potential edges

class Edge {
  // Draws and represents an edge between two nodes
  // Graph model should have a big old list of these

  //fields
  Agent a;
  Agent b;
  protected boolean highlight = false;

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
    return Objects.hash(x, y, "Edge");
  }
}

class MemberPotentialEdge extends Edge {
  Member member;
  Potential potential;

  MemberPotentialEdge(Member m_, Potential p_) {
    super(m_, p_);
    this.potential = p_;
    this.member = m_;
  }

  public void recruitPtoM() {
    // test test test
    edges.remove(this);
    mpEdges.remove(this);
    
    Member newMem = AtoM(this.potential);
    Edge ne = new Edge(newMem, this.member); // ne -> new edge
    ne.a.setPuller(this.member, ne);
    ne.highlight();
    //ne.store(); 
    activeCount++; 
    active.add(this);
  }

  public void display() {
    if (this.highlight) {
      strokeWeight(4);
      stroke(0, 125, 0);
    } else {
      strokeWeight(2);
      stroke(0, 0, 255);
    }

    line(a.coord.x, a.coord.y, b.coord.x, b.coord.y);
  }
}

class MemberFormerEdge extends Edge {
  Member member;
  Former former;

   MemberFormerEdge(Member m_, Former f_) {
    super(m_, f_);
    this.member = m_;
    this.former= f_;
  }
  
   public void recruitMtoF() {
    // test test test
    edges.remove(this);
    mfEdges.remove(this);
    
    Former newForm = AtoF(this.member);
    Edge ne = new Edge(newForm, this.former);
    ne.a.setPuller(this.former, ne);
    ne.highlight();
    activeCount++; 
    active.add(this);
  }
}
