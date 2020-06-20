import java.util.Arrays;
import processing.serial.*;
/* 
 * This is, for us, aleatoric television. -- The Books, "Be Good to Them Always"
 *
 * Attempted implementation of the DeGroot consensus model in Processing.
 * See "Reaching a Consensus," Morris H. Degroot, 1974
 * https://www.jstor.org/stable/2285509
 *
 */

//FIDDLE KNOBS

//static float[][] adjMat = 
//  {{.5, .5, 0, 0, 0}, 
//  {.25, .5, .25, 0, 0}, 
//  {.25, .25, .5, 0, 0}, 
//  {0, 0, .5, .5, 0}, 
//  {0, 0, .5, .5, 0}}; //weight adjacency matrix
//float[] ops = {1, 4, 10, 6, 7} ; //Starting opinions

//periodic graph on 8 nodes
static float[][] adjMat = 
  {{0, .5, .5, 0, 0, 0, 0, 0}, 
  {0, 0, 0, .5, 0, 0, 0, .5}, 
  {.5, 0, 0,.5, 0, 0, 0, 0}, 
  {0, .5, 0, 0, 0, .5, 0, 0}, 
  {0, 0, .5, 0, 0, 0, .5, 0}, 
  {0, 0, 0, 0, .5, 0, 0, .5}, 
  {.5, 0, 0, 0, .5, 0, 0, 0}, 
  {0, 0, 0, 0, 0, .5, .5, 0}}; //weight adjacency matrix
float[] ops = {1, 4, 10, 6, 7, 10, 3, 4, 5} ; //Starting opinions

// Op array is mantained in parallel with the individual nodes, accounting for 
// their opinions. Not the most elegant method, for sure, but it will have to do. 
//   Diameter of nodes is under Node

static int num = adjMat.length;
int tall = 1000;
int wide = 1000; 
int iter = 0;

//Globals
Node[] nodes = new Node[num];
float maxOp, minOp;
int counter_; // for setting up Node

void setup() {
  println(num);

  strokeWeight(2);
  size(1000, 1000);
  background(255);
  fill (125);

  initNodes();


  maxOp = nodes[0].getOp();
  minOp = nodes[0].getOp();
  //Find min and max ops
  for (Node n : nodes) {
    // appropriately set min and max op
    if (n.getOp() < minOp) { 
      minOp = n.getOp();
    }
    if (n.getOp() > maxOp) { 
      maxOp = n.getOp();
    }
  }
  circleCoords(num);

  stroke(0);
}

void draw() {
  background(255);


  stroke(34, 153, 255);
  fill(255);
  strokeWeight(2);
  for (int i= (int) (wide* 1.5); i > 1; i -= 100) {
    ellipse( tall/2, wide/2, i, i);
  }

  textSize(18);
  fill(0);
  text("iteration "+iter, 20, 20);
  textSize(14);

  stroke(0);
  fill(125);
  setupArrows();

  for (Node n : nodes) {
    n.drawCircle();
  }
  //print(Arrays.toString(ops));
  //ellipse(mouseX, mouseY, 10, 10);
  if (keyPressed) {
    stepAllOps();
    circleCoords(num);
    delay(500);
  }
}

void setupCirclesRand(int n) {
  // Draws the circles and writes them to coords

  for (int i = 0; i<n; i++) {
    PVector cur = randomCoord(nodes);
    nodes[i].setCoord(cur);
    ellipse(cur.x, cur.y, Node.DI, Node.DI);
    //if (prevX != -1) {
    //  arrow(prevX, prevY, cur.x, cur.y);
    //}
    //prevX = cur.x;
    //prevY = cur.y;
  }
}

void circleCoords(int n) {
  // Does the starting set-up of all the nodes coordinates
  float angle = 0; //in rads
  for (int i = 0; i<n; i++) {
    float diff = ((maxOp - minOp) > 0.001) ? (maxOp - minOp) : 1; //don't want a diff of 0
    float gain = 0.1 + ( (0.3 / diff) * (nodes[i].getOp() - minOp) );
    //random(0.1, 0.4);
    // I think this maps from minOp to maxOp porportionately to [0.1, 0.4]
    PVector cur = new PVector (wide/2 + gain * wide *cos(angle), tall/2 + gain * tall * sin(angle)); // modify
    nodes[i].setCoord(cur);
    // ellipse(cur.x, cur.y, 50, 50);
    angle += 2*PI/n;
  }
}
void setupArrows() {
  // Draws arrows of the appropriate thickness to connect the nodes
  final float MAX_THICC = 8;
  final float THICC_BOOST = .5;
  for (int i=0; i < num; i++) {
    for (int j = 0; j < num; j++) {
      if (adjMat[i][j] == 0) { 
        continue;
      }
      strokeWeight ( THICC_BOOST + MAX_THICC * adjMat[i][j]);
      //stroke(255, 34, 34); RED
      stroke(0);
      if (i != j) { //not a self edge
        pushMatrix();
        arrow(nodes[j], nodes[i]); 
        // Be careful about this. The way the information is stored in the matrix is the "oppisite"
        // of how the arrows point. (Because a larger arrow towards an agent represents more trust 
        // that agent puts in someone else.)
        popMatrix();
      } else {
        // is a self-edge
        selfArrow(nodes[i]);
      }
    }
  }
}

PVector randomCoord(Node[] nodes) {
  final int MIN_DISTANCE = 75;
  // given the matrix of coords, and a certain distance from the frame boundary
  //outputs a random coord a certain distance from any other coord and the frame.
  //Maybe to be replaced with circle action
  PVector output = new PVector(-1, -1);
  boolean i = true;
  final int BORDER = 20;

  int runCount = 0;
  while (i && (runCount < 20)) {
    output.set(random(BORDER, wide-BORDER), random (BORDER, tall-BORDER ));
    i = false;
    for (Node nod : nodes) {
      //if (nod.getCoord().x == -1) {
      //  // This is a dummy starting value
      //  continue;
      //}
      boolean notGood =(output.dist(nod.getCoord() ) <  MIN_DISTANCE);
      if (notGood) {
        i = true;
        break;
      }
    }
    runCount++;
  }
  return output;
}

void arrow (Node begin, Node end) {
  // Draws arrow from begin to end. Arrow points towards end.
  // For nodes, the arrow will be modified slightly 

  //Translate from nodes to floats
  float x1 = begin.getCoord().x;
  float y1 = begin.getCoord().y;
  float x2 = end.getCoord().x;
  float y2 = end.getCoord().y;

  float deltaX = x2-x1;
  float deltaY = y2 -y1;
  float r = Node.R;

  float a = getDirection(deltaX, deltaY);
  final float mod = 0.4;
  simpleArrow(x1 + r*cos(a+mod), y1 + r*sin(a + mod), x2 - r*cos(a - mod), y2 - r*sin(a - mod)); //from 1 to 2

  //arrow(x1, y1, x2, y2);
} 

void simpleArrow(float x1, float y1, float x2, float y2) {
  // Draws arrow from (x1, y1) to (x2, y2). No adjustment.
  float deltaX = x2-x1;
  float deltaY = y2-y1;

  line(x1, y1, x2, y2);
  //print("b is "+b + " startX is " +startX + " startY is "+ startY);
  arrowHead(x2, y2, deltaX, deltaY);
} 


void arrowHead(float endX, float endY, float deltaX, float deltaY) {
  //Arrowhead helper method
  pushMatrix();
  translate(endX, endY);
  float a = atan2(-deltaX, deltaY);
  rotate(a);
  line(0, 0, -10, -10);
  line(0, 0, 10, -10);
  popMatrix();
}

void selfArrow(Node n) {
  fill(125, 0);
  PVector cur = n.getCoord();
  pushMatrix();
  translate (cur.x, cur.y);
  if (cur.x < 250) {
    rotate(PI);
  }
  bezier( sqrt(2)/2 * Node.R, - (sqrt(2)/2 *  Node.R), 100, -60, 100, 60, sqrt(2)/2 *  Node.R, (sqrt(2)/2 *  Node.R));
  popMatrix();
  fill(125);
  //arrowHead(sqrt(2)/2 * 25, (sqrt(2)/2 * 25), 70 - sqrt(2)/2 * 25, 40 - (sqrt(2)/2 * 25)); //Fix
}

void initNodes () {
  // construct all the circles with a dummy value
  for (int i = 0; i < num; i++) {
    //init coords to dummy value
    nodes[i] = new Node(-1, -1, ops[i]);
  }
}

void stepAllOps() {
  // In essence, this is a slow way of doing matrix multiplication on a per-node basis
  // Calculates a weighted avg of opinions 
  //for every node, this goes into the rafters, then the nodes update all at once.
  //    In a different world, I might have put this under Node()
  for (int i = 0; i < num; i++) {
    float weightedAvg = 0;
    for (int j = 0; j < num; j++) {
      weightedAvg += adjMat[i][j]*nodes[j].getOp();
    }
    nodes[i].setOStar(weightedAvg);
    ops[i] = weightedAvg;
    // the opinions in ops are updated slightly before the opinions in the nodes...
    // be careful.
  }

  //Set all o = ostar
  for (Node n : nodes) {
    n.updateOp();
  }

  iter++;
}

float getDirection(float dx, float dy) {
  return atan2(dy, dx);
}
