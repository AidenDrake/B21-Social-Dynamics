/**
 * Agent for our ABM
 */

class Agent {
  // There's a set radius for all agents
  public static final float agentRadius = 2.5;

  //Fields
  PVector coord;
  char group; //'M', 'P', or 'F'
  PVector velocity;


  //Contstructor
  public Agent(PVector inputCoord, char inputGroup) {
    this.coord = inputCoord;
    this.group = inputGroup;
    this.velocity = PVector.random2D();
    velocity.mult(3);
  }

  //Methods
  public void update() {
    //if (keyPressed && key == 's'){
    //  velocity = velocity.mult(0.9);
    //}
    //if (keyPressed && key == 'a'){
    //  velocity = velocity.mult(1.1);
    //}
    coord.add(velocity);
  }

  public void display() {
    noStroke();
    fill(0);
    ellipse(coord.x, coord.y, agentRadius*2, agentRadius*2);
  }
  
  public void checkCollision(float bigRadius){
    // Collisions against the "outer wall" of the big circle
    // Adapted from the processing "Collisions" example
    
    final PVector center = new PVector(0, 0);
    
    //vector distance to center
    PVector centerDistanceVect = PVector.sub(coord, center);
    
    //magnitude of distance to center
    float centerDistanceMag = centerDistanceVect.mag();
    
    //Maximum distance before touching edge
    float maxDist = bigRadius-agentRadius;
    
    if (centerDistanceMag > maxDist){
      //this.coord = new PVector(0,0);
      
      float correction = (centerDistanceMag - maxDist) / 2.0;
      PVector d = centerDistanceVect.copy();
      PVector correctionVector = d.normalize().mult(correction);//*4?
      coord.sub(correctionVector);
      
      //angle of center vect
      float theta = centerDistanceVect.heading();
      
      //trig values
      float sine = sin(theta);
      float cosine = cos(theta);
      
      stroke(255, 0, 0);
      line(coord.x, coord.y, coord.x+cosine*20, coord.y+sine*20);
      
      PVector neg = center.sub(centerDistanceVect);
      
      PVector normalNeg = neg.normalize();
      
      PVector newVel = normalNeg.mult(velocity.mag());
      
      velocity = newVel;
    }
    
    println("center distance mag is: "+centerDistanceMag);
  }
}
