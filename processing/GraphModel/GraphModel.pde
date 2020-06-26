/** 
 * An agent based simulation based off Hedstrom's ODE model of social groups.
 * 
 * Work in progress
 */

ArrayList<Agent> agents = new ArrayList();

void setup() {
  size(1000, 1000);
  PVector a = new PVector(30, 30);

  agents.add(new Agent((new PVector(200, 200)), (new PVector(2.10, -0.76)), 'F'));
  //for (int i = 0; i < 9; i++) {
  //  agents.add(new Agent((PVector.random2D().mult(200)), 'M'));
  //}
}

void draw() {
  background(245);
  stroke(0);

  pushMatrix();
  translate(width/2, height/2);

  float bigRadius = 400;

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

  for (Agent a : agents) {
    a.update();
    a.display();
    a.checkBigCollision(bigRadius);
    a.checkLineCollision();
  }
  popMatrix();
}
