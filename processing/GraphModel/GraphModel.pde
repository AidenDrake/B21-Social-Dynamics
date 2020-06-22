/** 
 * An agent based simulation based off Hedstrom's ODE model of social groups.
 */
int wide = 800;
int tall = 800;

void setup() {
  size(800, 800);
}

void draw() {
  background(245);
  stroke(0);
  
  pushMatrix();
  translate(wide/2,tall/2);
  rotate(radians(210));
  float radius = 600;
  fill(255, 0, 51, 125); //light red
  arc(0, 0, radius, radius, 0, TAU/3, PIE);
  fill(0, 153, 255, 125); //light blu
  arc(0, 0, radius, radius, TAU/3, 2*TAU/3, PIE);
  fill(255, 255, 0, 125); //light yellow
  arc(0, 0, radius, radius, 2*TAU/3, TAU, PIE);
  popMatrix();
}
