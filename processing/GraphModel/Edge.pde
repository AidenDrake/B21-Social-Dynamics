/**
 * "So, I hear you're a real edgelord" -- XKCD #2036
 * 
 * Edges for the model, which represent social connections between agents
 * in a community.
 **/
public HashSet<Edge> edges = new HashSet<Edge>();

public ArrayList<Edge> mfEdges = new ArrayList<Edge>();
public ArrayList<Edge> mpEdges = new ArrayList<Edge>();

class Edge {
  // Draws and represents an edge between two nodes
  // Graph model should have a big old list of these

  //fields
  Agent a;
  Agent b;
  private boolean highlight = false;

  public Edge(Agent _a, Agent _b) {
    this.a = _a;
    this.b = _b;

    boolean hasPotential = a instanceof Potential || b instanceof Potential; //get it?
    boolean memberStatus = a instanceof Member || b instanceof Member;
    boolean isFormative = a instanceof Former || b instanceof Former;


    if (isFormative && memberStatus) {
      mfEdges.add(this);
    }
    if (hasPotential && memberStatus) {
      mpEdges.add(this);
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
    this.highlight = true;
  }

  public void successfulRecruit() {
    //Make private
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
}
