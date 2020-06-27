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
  
   public void highlight(){
    this.highlight = true;
  }
  
  public void unHighlight(){
    this.highlight = true;
  }
  
  public void successfulRecruit(){
    //Make private
    highlight = true;
    
  }
}
