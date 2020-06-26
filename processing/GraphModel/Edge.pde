class Edge{
  // Draws and represents an edge between two nodes
  // Graph model should have a big old list of these
 
 //fields
  Agent a;
  Agent b;
  
  public Edge(Agent _a, Agent _b){
    this.a = _a;
    this.b = _b;
  }
  
  public void display(){
    strokeWeight(1);
    stroke(125);
    line(a.coord.x, a.coord.y, b.coord.x, b.coord.y);
  }
}
