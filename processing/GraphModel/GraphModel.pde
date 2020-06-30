/** 
 * An agent based simulation based off Hedstrom's ODE model of social groups.
 * 
 * Work in progress
 */
import java.util.HashSet;
import java.util.Objects;

public final static float bigRadius = 400;

ArrayList<Agent> agents = new ArrayList<Agent>(); 

int j = 0;

void setup() {
  size(1000, 1000);
  PVector a = new PVector(30, 30);

  //agents.add(new Agent((new PVector(200, 200)), (new PVector(2.10, -0.76))));
  for (int i = 0; i < 10; i++) {
    agents.add(new Potential());
  }

  Potential steve = new Potential();
  agents.add(steve);


  Member milo = new Member();
  agents.add(milo);

  //Edge e = new Edge(steve, milo);
  //edges.add(e);

  for (int i = 0; i < 9; i++) {
    agents.add(new Member());
  }

  for (int i = 0; i < 9; i++) {
    agents.add(new Former());
  }

  for (int i = 0; i < 10; i++) {
    //println(edges);
    newRandEdge();
  }

  //Edge egan = edges.get(0);
  //egan.highlight();

  println(members + "  "+ members.size());
  println("mp edges is " + mpEdges);
  println("mf edges is " + mfEdges + "  "+ members.size());
}

void draw() {
  background(245);
  stroke(0);

  pushMatrix();
  translate(width/2, height/2);

  //PVector mouse = new PVector(mouseX-width/2, mouseY-height/2);
  //stroke(0, 0, 125);
  ////line(20, 20, mouse.x, mouse.y);
  //float angle = atan2(mouse.y, mouse.x);
  //line(20, 20, cos(angle)*300, sin(angle)*300);


  //if (angle < 0) {
  //  angle = (2*PI+angle);
  //}

  //fill(0);
  //textSize(32);
  //text ("angle :" + degrees(angle), -300, -300);
  
  drawBigCircle();

  for (Edge e : edges) {
    e.display();
  }

  for (Agent a : agents) { 
    a.display();
  }

  if (keyPressed && key == ' ') {
    for (Agent a : agents) {
      a.update();
    }
  }

  if (mousePressed && (j < 1)) {
    agents.set(1, AtoP(agents.get(1)));
    //println(agents.get(0).getType());
    
    Agent c= agents.get(0);
    Agent d = agents.get(1);

    d.setPuller(c);
    j++;
  }


  popMatrix();
}

Agent randAgent() {
  int index = int(random(0, agents.size()));
  return agents.get(index);
}

void newRandEdge() {
  //println("this ran");
  int j = 0;
  Edge e = null;
  //println("contains e? " + edges.contains(e));
  while (((edges.contains(e)) && j<20) || e == null ) { // avoid duplicate edges
    // j is a dumb hack to avoid an infinite loop
    Agent randy = randAgent();
    Agent randall = randAgent();
    while (randy.equals(randall)) { // if we pick one that's the same, pick again
      randall = randAgent();
    }
    e = new Edge(randy, randall);
    j ++;
    //println("new e is "+e);
  }
  e.store();
  //println("added "+e);
}

void drawBigCircle() {
  // Draw the big circle.
  // the wonky angles make it look pretty.
  // eventually this should work with the bounds array
  fill(255, 0, 51, 125); //light red
  arc(0, 0, bigRadius*2, bigRadius*2, 7*PI/6, 11*PI/6, PIE);
  fill(0, 153, 255, 125); //light blu
  arc(0, 0, bigRadius*2, bigRadius*2, 11*PI/6, 15*PI/6, PIE);
  fill(255, 255, 0, 125); //light yellow
  arc(0, 0, bigRadius*2, bigRadius*2, 15*PI/6, 19*PI/6, PIE); 
  //aka from PI/2 == 3PI/6 to 7PI/6
}
