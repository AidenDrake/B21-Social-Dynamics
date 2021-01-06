/**  //<>// //<>//
 * A visual, agent based simulation based off Hedstrom's ODE model of social groups.
 * 
 * “At sufficiently high levels of abstraction, the logic of many of the processes studied 
 * by epidemiologists, biologists, and sociologists are virtually isomorphic...
 * Formal models required for analyzing social processes rarely need to be invented from scratch.”
 * -- Peter Hedstrom
 *
 * See P Hedstrom. Explaining the growth patterns of social movements.
 * Understanding Choice, Explaining Behavior. (Oslo University Press,
 * Norway, 2006).
 *
 * Work in progress
 */
import java.util.HashSet;
import java.util.Objects;
import java.util.LinkedList;
import java.util.Iterator;

public final static float bigRadius = 400;

HashSet<Agent> agents = new HashSet<Agent>(); 
HashSet<Edge> active = new HashSet<Edge>();
EdgeRecordStorage edgeRecs;

int j = 0;
int step = 0;

int activeCount = 0;

void setup() {
  size(1000, 1000);

  rectMode(CENTER);

  initAgentTypes();

  //Agent p = new Agent(potential);

  //Agent m = new Agent(member);

  //EdgeRecord er = new EdgeRecord(m, p);

  edgeRecs = new EdgeRecordStorage(agents);
  //edgeRecs.store(er);

  for (int i = 0; i < 9; i++) {
    agents.add(new Agent(member));
  }

  for (int i = 0; i < 9; i++) {
    agents.add(new Agent(former));
  }

  for (int i = 0; i < 10; i++) {
    agents.add(new Agent(potential));
  }


  //  for (int i = 0; i < 20; i++) {
  //    edgeRecs.newRandEdgeRecord();
  //  }
}

void draw() {
  background(245);
  stroke(0);

  pushMatrix();
  translate(width/2, height/2);

  drawBigCircle();

  displayEdges();

  updateEdges();

  displayAgents();

  updateAgents();



  if (keyPressed && key =='k') {
    j++;
  }
  if (j == 1) {
    HashSet<Agent> mpointers = (HashSet<Agent>) members.clone();
    for (Agent m : mpointers) {
      m.defectTo(former);
    }
    print("event" + j);
  }
  if (j == 10) {
    HashSet<Agent> fpointers = (HashSet<Agent>) formers.clone();
    for (Agent f : fpointers) {
      f.defectTo(potential);
    }
    print("event" + j);
  }

  //println(
  popMatrix();

  text("drawnEdges: " + drawnEdges.size() + "MP Edges: " + mpEdges.size() + " Step: "+ step +" ActiveCount: " + activeCount, 20, 20);
  //println("Agents: " + agents);
}

private void displayEdges() {
  for (Edge e : drawnEdges) {
    e.display();
  }
}

private void updateEdges() {
  drawnEdges.clear();
  for (EdgeRecord er : edgeRecs) {
    er.remakeEdge();
    drawnEdges.add(er.edge);
  }
  //println(drawnEdges);
}
private void displayAgents() {
  for (Agent a : agents) { 
    a.display();
  }
}
private void updateAgents() {
  for (Agent a : agents) {
    a.update();
  }
}


private void drawBigCircle() {
  // Draw the big circle.
  // the wonky angles make it look pretty.
  // eventually this should work with the bounds array
  strokeWeight(1);
  fill(255, 0, 51, 125); //light red
  arc(0, 0, bigRadius*2, bigRadius*2, 7*PI/6, 11*PI/6, PIE);
  fill(0, 153, 255, 125); //light blu
  arc(0, 0, bigRadius*2, bigRadius*2, 11*PI/6, 15*PI/6, PIE);
  fill(255, 255, 0, 125); //light yellow
  arc(0, 0, bigRadius*2, bigRadius*2, 15*PI/6, 19*PI/6, PIE); 
  //aka from PI/2 == 3PI/6 to 7PI/6
}

void startStep() {
  step++;

  //Hedstrom's parameters
  float alpha = 0.1;
  float beta = 0.1;
  float phi = 0.01;
  float c = 0.01;

  //refillEdges();

  recruitPotentialsToMembers(mpEdges, alpha);

  recruitMembersToFormers(mfEdges, beta);

  defectFormers(formers, phi);

  defectMembers(members, c);
}


private void recruitMembersToFormers(HashSet<MemberFormerEdge> mfEdges, float beta) {
  HashSet<MemberFormerEdge> mfpointers = (HashSet<MemberFormerEdge>) mfEdges.clone();
  for (MemberFormerEdge e : mfpointers ) {
    if (random(1) <= beta) {
      if (! active.contains(e)) {
        // e.recruitMtoF();
      }
    }
  }
}

private void recruitPotentialsToMembers(HashSet<MemberPotentialEdge> mpEdges, float alpha) {
  HashSet<MemberPotentialEdge> pointers = (HashSet<MemberPotentialEdge>) mpEdges.clone();
  for (MemberPotentialEdge e : pointers ) {
    if (random(1) <= alpha) {
      if (! active.contains(e)) {
        e.recruitPtoM();
      }
    }
  }
}

private void defectFormers(HashSet<Agent> formers, float phi) {
  HashSet<Agent> fpointers = (HashSet<Agent>) formers.clone();
  for (Agent f : fpointers) {
    if (random(1) <= phi) {
      f.defectTo(potential);
    }
  }
}

private void defectMembers(HashSet<Agent> members, float c) {
  HashSet<Agent> mpointers = (HashSet<Agent>) members.clone();
  for (Agent m : mpointers) {
    if (random(1) <= c) {
      m.defectTo(former);
    }
  }
}
