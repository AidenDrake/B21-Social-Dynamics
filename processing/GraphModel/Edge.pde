/** //<>//
 * "So, I hear you're a real edgelord" -- XKCD #2036
 * 
 * Edges for the model, which represent social connections between agents
 * in a community.
 **/
public HashSet<Edge> edges = new HashSet<Edge>();

public HashSet<MFEdge> mfEdges = new HashSet<MFEdge>(); // member - former edges
public HashSet<MPEdge> mpEdges = new HashSet<MPEdge>(); //Member - potential edges

class Edge {
  // Draws and represents an edge between two nodes
  // Graph model should have a big old list of these

  //fields
  Agent a;
  Agent b;
  protected boolean highlight = false;

  //Constructor for a "generic edge"
  public Edge(Agent _a, Agent _b) {
    this.a = _a;
    this.b = _b;
  }

  public Edge() {
  } //super constructor

  public void store() {
    // takes this, transforms it into a subclass if necessary, and stores it in the 
    // edges hash set, or possibly the list of MF_ or MP_ edges. 
    boolean hasPotential = a instanceof Potential || b instanceof Potential;
    boolean memberStatus = a instanceof Member || b instanceof Member;
    boolean isFormative = a instanceof Former || b instanceof Former;

    if (hasPotential && memberStatus) {
      // If M - P edge, let's make one of those and store it instead of a 
      // generic edge.
      MPEdge mpe = new MPEdge(this.getMember(), this.getPotential());

      mpEdges.add(mpe);
      edges.add(mpe);
    } else if (isFormative && memberStatus) {
      // If M - F edge, same as above
      MFEdge mfe = new MFEdge(this.getMember(), this.getFormer());
      mfEdges.add(mfe);
      edges.add(mfe);
    } else { 
      // otherwise, let's store as a generic edge
      edges.add(this);
    }
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
    this.highlight = false;
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
    return Objects.hash(x, y, "Edge");
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
  
  public Agent getA(){
    return this.a;
  }
  
  public Agent getB(){
    return this.b;
  }
}

class MPEdge extends Edge {
  Member m;
  Potential p;

  MPEdge(Member m_, Potential p_) {
    super(m_, p_);
    this.p = p_;
    this.m= m_;
  }

  public void recruitPtoM() {
    // test test test
    edges.remove(this);
    mpEdges.remove(this);
    
    Member newMem = AtoM(this.p);
    Edge ne = new Edge(newMem, this.m); // ne -> new edge
    ne.a.setPuller(this.m, ne);
    ne.highlight();
    ne.store(); 
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

class MFEdge extends Edge {
  Member m;
  Former f;

  MFEdge(Member m_, Former f_) {
    super(m_, f_);
    this.m = m_;
    this.f= f_;
  }
  
   public void recruitMtoF() {
    // test test test
    edges.remove(this);
    mfEdges.remove(this);
    
    Former newForm = AtoF(this.m);
    Edge ne = new Edge(newForm, this.f);
    ne.a.setPuller(this.f, ne);
    ne.highlight();
    ne.store(); 
    activeCount++; 
    active.add(this);
  }
}
