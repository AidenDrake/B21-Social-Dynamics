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
  
  public Agent(PVector inputCoord, PVector inputVelocity, char inputGroup) {
    this.coord = inputCoord;
    this.group = inputGroup;
    this.velocity = inputVelocity;
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

  public void checkCollision(float bigRadius) {
    // Collisions against the "outer wall" of the big circle
    // Adapted from the processing "Collisions" example

    final PVector center = new PVector(0, 0);

    //vector distance to center
    PVector centerDistanceVect = PVector.sub(coord, center);

    //magnitude of distance to center
    float centerDistanceMag = centerDistanceVect.mag();

    //Maximum distance before touching edge
    float maxDist = bigRadius-agentRadius;

    //this.coord = new PVector(0,0);

// Move stuff below into if statement. It was taken out for debug
    float correction = (centerDistanceMag - maxDist) / 2.0;
    PVector d = centerDistanceVect.copy();
    PVector correctionVector = d.normalize().mult(correction*4);//*4?


    //angle of center vect
    float theta = centerDistanceVect.heading();

    //trig values
    float sine = sin(theta);
    float cosine = cos(theta);

    // collision line for debug
    stroke(255, 0, 0);
    line(coord.x, coord.y, coord.x+cosine*20, coord.y+sine*20);
    
    //vel line for debug
    stroke(0, 200, 0);
    line(coord.x, coord.y, coord.x+velocity.x*20, coord.y+velocity.y*20);

    if (centerDistanceMag > maxDist) {
      coord.sub(correctionVector);

      // this is not at all right right now
      PVector newVel = new PVector(0, 0);
      newVel.x  = cosine * velocity.x - sine * velocity.y;
      newVel.y  = cosine * velocity.y + sine * velocity.x;

      //PVector neg = center.sub(centerDistanceVect);

      //PVector normalNeg = neg.normalize();

      //PVector newVel = normalNeg.mult(velocity.mag());

      velocity = newVel;
    }

    //println("center distance mag is: "+centerDistanceMag);
  }
  
  public void flatCollision(float m, float b) {
    boolean isCollision = (floor((coord.x*m+b))) > (floor(coord.y));
    if (isCollision) {
      velocity = new PVector(0, 0);
    }
    
  }
}