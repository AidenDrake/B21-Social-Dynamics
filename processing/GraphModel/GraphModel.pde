/** 
 * An agent based simulation based off Hedstrom's ODE model of social groups.
 * 
 * Work in progress
 */
int wide = 1000;
int tall = 1000;
ArrayList<Agent> agents = new ArrayList();

void setup() {
  size(1000, 1000);
  PVector a = new PVector(30, 30);
  for (int i = 0; i < 9; i++) {
    agents.add(new Agent((PVector.random2D().mult(200)), 'M'));
  }
}

void draw() {
  background(245);
  stroke(0);

  pushMatrix();
  translate(wide/2, tall/2);

  pushMatrix();
  rotate(radians(210));
  float bigRadius = 400;
  fill(255, 0, 51, 125); //light red
  arc(0, 0, bigRadius*2, bigRadius*2, 0, TAU/3, PIE);
  fill(0, 153, 255, 125); //light blu
  arc(0, 0, bigRadius*2, bigRadius*2, TAU/3, 2*TAU/3, PIE);
  fill(255, 255, 0, 125); //light yellow
  arc(0, 0, bigRadius*2, bigRadius*2, 2*TAU/3, TAU, PIE);
  popMatrix();

  for (Agent a : agents) {
    a.update();
    a.display();
    a.checkCollision(bigRadius);
  }
  popMatrix();
}
