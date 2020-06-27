/** 
 * An agent based simulation based off Hedstrom's ODE model of social groups.
 * 
 * Work in progress
 */

public final static float bigRadius = 400;

ArrayList<Agent> agents = new ArrayList();
ArrayList<Edge> edges = new ArrayList(); 

void setup() {
  size(1000, 1000);
  PVector a = new PVector(30, 30);

  //agents.add(new Agent((new PVector(200, 200)), (new PVector(2.10, -0.76))));
  //for (int i = 0; i < 1; i++) {
  //  agents.add(new Pot());
  //}
  
  Pot steve = new Pot();
  agents.add(steve);
  
  Mem milo = new Mem();
  agents.add(milo);
  
  Edge e = new Edge(steve, milo);
  edges.add(e);

  //for (int i = 0; i < 2; i++) {
  //  agents.add(new Mem());
  //}

  //for (int i = 0; i < 45; i++) {
  //  agents.add(new Former());
  //}

  //for (int i = 0; i < 2; i++) {
  //  newRandEdge();
  //}

  //Edge egan = edges.get(0);
  //egan.highlight();
}

void draw() {
  background(245);
  stroke(0);

  pushMatrix();
  translate(width/2, height/2);

  // Draw the big circle.
  // the wonky angles make it look pretty.

  fill(255, 0, 51, 125); //light red
  arc(0, 0, bigRadius*2, bigRadius*2, 7*PI/6, 11*PI/6, PIE);
  fill(0, 153, 255, 125); //light blu
  arc(0, 0, bigRadius*2, bigRadius*2, 11*PI/6, 15*PI/6, PIE);
  fill(255, 255, 0, 125); //light yellow
  arc(0, 0, bigRadius*2, bigRadius*2, 15*PI/6, 19*PI/6, PIE); 
  //aka from PI/2 == 3PI/6 to 7PI/6

  PVector mouse = new PVector(mouseX-width/2, mouseY-height/2);
  stroke(0, 0, 125);
  ////line(20, 20, mouse.x, mouse.y);
  float angle = atan2(mouse.y, mouse.x);
  //line(20, 20, cos(angle)*300, sin(angle)*300);


  if (angle < 0) {
    angle = (2*PI+angle);
  }

  fill(0);
  textSize(32);
  //text ("angle :" + degrees(angle), -300, -300);

  for (Edge e : edges) {
    e.display();
  }

  for (Agent a : agents) { 
    a.display();
  }
  
  for (Agent a : agents) {
    a.update();
    a.checkBigCollision(bigRadius);
    a.checkLineCollision();
  }
  
  Agent steve = agents.get(0);
  Agent milo = agents.get(1);
  
  steve.setPuller(milo);

  popMatrix();
}

Agent randAgent() {
  int index = int(random(0, agents.size()));
  return agents.get(index);
}

void newRandEdge() {
  Edge e = new Edge(randAgent(), randAgent());
  edges.add(e);
}
