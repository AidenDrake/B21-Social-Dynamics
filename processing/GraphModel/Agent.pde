/**
 * Agent for our ABM
 */
 
public static final float bounds[] = {0, PI/2, 7*PI/6, 11*PI/6};
//bounds[] is theta of lines 1, 2, & 3 respectively. The zero is a spacer.

class Agent {
  // There's a set radius for all agents
  public static final float agentRadius = 2.5;
  
  // we're also going to get the bounds and bigRadius as finals:
  public static final float bigRadius = GraphModel.bigRadius;

  //Fields
  PVector coord;
  char group; //'M', 'P', or 'F'
  PVector velocity;


  //Constructor -- this one to make a "Generic" agent for debug
  public Agent(PVector inputCoord, PVector inputVelocity) {
    this.coord = inputCoord;
    this.velocity = inputVelocity;
  }
  
  //Each subclass will have its own random constructor
  protected Agent(){ 
  }


  //Public methods
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

    //debug
    //textSize(16);
    //text("velocity: <"+velocity.x+","+velocity.y+">", coord.x -20, coord.y-20);
  }


  public void checkBigCollision(float bigRadius) {
    // Collisions against the "outer wall" of the big circle
    // Correction vector procedure adapted from the processing "Collisions" example

    final PVector center = new PVector(0, 0);

    //vector distance to center
    PVector centerDistanceVect = PVector.sub(coord, center);

    //magnitude of distance to center
    float centerDistanceMag = centerDistanceVect.mag();

    //Maximum distance before touching edge
    float maxDist = bigRadius-agentRadius;

    //vel line for debug
    stroke(0, 200, 0);
    line(coord.x, coord.y, coord.x+velocity.x*20, coord.y+velocity.y*20);

    if (centerDistanceMag > maxDist) {
      // if collision with outside

      //Calculate correction vector, which scoots the agent back inside the circle
      float correction = (centerDistanceMag - maxDist) / 2.0;
      PVector d = centerDistanceVect.copy();
      PVector correctionVector = d.normalize().mult(correction);

      coord.sub(correctionVector);

      // Collide as if hitting a line tanget to the circle, that is, perpendicular to the 
      // center distance vect. 
      this.velocity = getNewVel(getPerpen(centerDistanceVect), true);
    }
  }


  public void checkLineCollision() {
    float angle = atan2(coord.y, coord.x);
    if (angle < 0) {
      angle = (2*PI+angle);
    }
    float hitAngle = 99; 

// let's get rid of this switch eventually
    switch (this.group) {
    case 'P':
      if ((angle < (PI/2))) {
        // colliding with line 3
        hitAngle = PI/2;
      }

      //colliding with line 1
      if (angle > (7*PI/6)) {
        hitAngle = 7*PI/6;
      }
      break;
      
    case 'M':

      //colliding with line 1
      if (angle < (7*PI/6)) {
        hitAngle = 7*PI/6;
      }

      //colliding with line 2
      if (angle > (11*PI/6)) {
        hitAngle = 11*PI/6;
      }
      break;
      
      case 'F':
      //colliding with line 2
      if ((angle > PI) && (angle < (11*PI/6))) {
        hitAngle = 11*PI/6;
      }
      
      //colliding with line 3
      if ((angle < PI) && (angle > (PI/2))) {
        // colliding with line 3
        hitAngle = PI/2;
      }
      
    }


    if (hitAngle != 99) {
      PVector collide = new PVector(cos(hitAngle)*bigRadius, sin(hitAngle)*bigRadius);
      PVector newVel = getNewVel(collide, true);
      velocity = newVel;
    }
  }

  //Protected methods
  protected PVector getNewVel(PVector wall, boolean flip) {
    PVector velocopy = velocity.copy();

    PVector perpen = getPerpen(wall);
    if (flip) {
      perpen.mult(-1);
    }

    PVector normalPerp = perpen.normalize();
    PVector white = proj(normalPerp, velocopy);
    //coord = coord.add(white);

    int mod = flip ? -2 : 2;

    PVector out = velocopy.add(white.mult(mod));

    return out ;
  }
}

//OOP city here we come, I didn't go to fancy programming school for nothing
class Pot extends Agent{
  
  //Constructor 1 -- debug
  public Pot(PVector inputCoord, PVector inputVel) {
    super(inputCoord, inputVel);
  }
  
  public Pot(){
    //Randomized constructor
    float theta = random(bounds[1], bounds[2]);
    coord = new PVector ((bigRadius - 10)*cos(theta), (bigRadius - 10)*sin(theta));
    velocity = PVector.random2D().mult(3);
  }
}
