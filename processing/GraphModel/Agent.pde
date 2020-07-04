/**
 * Agent for our ABM
 */

public static final float bounds[] = {0, PI/2, 7*PI/6, 11*PI/6};
//bounds[] is theta of lines 1, 2, & 3 respectively. The zero is a spacer.

public ArrayList<Potential> potentials = new ArrayList();
public ArrayList<Member> members = new ArrayList();
public ArrayList<Former> formers = new ArrayList();

static int counter = 1;

class Agent {
  // There's a set radius for all agents
  public static final float agentRadius = 2.5;

  // we're also going to get the bounds and bigRadius as finals:
  public static final float bigRadius = GraphModel.bigRadius;


  //Fields
  public PVector coord;
  PVector velocity;
  float rmsq; //resting magnituded squared (could (should??) be removed);

  public Agent puller = null;
  boolean isPulled = false;
  boolean centerCollide = true;
  int index = counter;
  Edge pullEdge = null; 


  //Constructors
  // this one to make a "Generic" agent for debug
  public Agent(PVector inputCoord, PVector inputVelocity) {
    this.coord = inputCoord;
    this.velocity = inputVelocity;
  }

  // this one is used for conversions
  protected Agent(Agent a) {
    this.coord = a.coord;
    this.velocity = a.velocity;
    this.rmsq = a.rmsq;
    this.puller = a.puller;
    this.isPulled = a.isPulled;
    this.centerCollide = a.centerCollide;
    this.index = a.index;
    this.pullEdge = a.pullEdge;
  }

  //Each subclass will have its own random constructor
  protected Agent() {
  }

  // ***MUY IMPORTANTE*** - Constructor to be used by subclasses
  protected Agent(int lbi, int ubi, float speed) {
    // Each subclass provides the Lower Bound Index and Upper Bound index
    // to specify the lines that they bounce off of. The speed is also set 
    // on a subclass basis. This function takes those parameters and makes 
    // an agent of the appropriate type.
    float theta;
    if (lbi > ubi ) {
      // this is to handle formers. Bit of a messy fix.
      theta = random((2*PI-bounds[3]), bounds[1]);
    } else {
      theta = random(bounds[lbi], bounds[ubi]);
    }  

    // generate a random distance from center,
    // and a random angle from center to randomly place the agent.
    float dist = random(10, (bigRadius - 10));
    coord = new PVector (dist*cos(theta), dist*sin(theta)); 
    velocity = PVector.random2D().mult(speed);

    this.rmsq = velocity.magSq();
    this.index = counter++;
  }


  //Public methods
  public void update() {
    if (isPulled) {
      this.getsPulled();
    }
    this.checkBigCollision(bigRadius);

    if (this.centerCollide) {
      this.checkLineCollision();
    }
    coord.add(velocity);
  }

  public void display() {
    noStroke();
    fill(0);
    ellipse(coord.x, coord.y, agentRadius*2, agentRadius*2);

    //debug
    textSize(16);
    //text("velocity: <"+velocity.x+","+velocity.y+">", coord.x -20, coord.y-20);
    //text("zone: "+this.getZone(), coord.x -20, coord.y-20);
    text(this.toString(), coord.x-10, coord.y-10);
  }

  public void setPuller(Agent a, Edge e) {
    //initiates pulling process. Should be called from edge
    this.puller = a;
    this.isPulled = true;
    this.centerCollide = false;
    println(""+this+" is pulled by "+a);
    this.pullEdge = e;
  }


  public char getType() {
    return 'S'; //SUPER
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

    // vel line for debug
    //stroke(0, 200, 0);
    //line(coord.x, coord.y, coord.x+velocity.x*10, coord.y+velocity.y*10);

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

  @Override
    public String toString() {
    return (this.getType() + " #"+ index);
  }

  public void checkLineCollision() {
    // will be implemented by the subclasses
  }  



  @Override
    public boolean equals(Object obj) {
    if (obj instanceof Agent) {
      Agent a = (Agent) obj;
      return (a.index == this.index);
    } else { 
      return false;
    }
  }

  @Override
    public int hashCode() {
    int a = 99; 
    return Objects.hash(this.index, "Agent");
  }

  //Protected methods
  protected float getAngle() {
    float angle = atan2(coord.y, coord.x);

    // adjust so no negative angles (a personal preference)
    if (angle < 0) {
      angle = (2*PI+angle);
    }

    return angle;
  }

  protected void doCollision(float hitAngle) {
    PVector collide = new PVector(cos(hitAngle)*bigRadius, sin(hitAngle)*bigRadius);
    PVector newVel = getNewVel(collide, true);
    velocity = newVel;
  }

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

  protected Float hitEval(float angle, int lowerIndex, int upperIndex) {
    // returns theta of collison line if there is one, else returns null;
    float theta1 = bounds[lowerIndex];
    float theta2 = bounds[upperIndex];
    float evalAngle = angle;
    float evalTheta2 = theta2;

    if (theta2 < theta1) {
      // if the "upper bound" is in fact, a smaller angle in radians than the lower bound
      // we have to adjust the angles as follows. The upper bound += 2PI so that 
      // PI/2 becomes, for instance, 5PI/2. ...
      evalTheta2 += 2*PI;

      //... Then if the angle is beyond 2PI degrees, instead
      //of starting the radian count over from zero, we add 2PI
      if (angle < (theta1 - PI)) {
        // PI is for some margin of safety when agents stray beyond the lower bound

        evalAngle += 2*PI;
      }
    }

    Float hitAngle = null;

    if (evalAngle < theta1) {
      hitAngle = theta1;
    }

    if (evalAngle > evalTheta2) {
      hitAngle = theta2;
    }

    return hitAngle;
  }

  public int getIndex() {
    return this.index;
  }

  public char getZone() {
    //make protected
    float angle = getAngle();


    // if farther away from the circle than radius break or fix in some way

    if (angle >= bounds[1] && angle <= bounds[2]) {
      return 'P';
    }

    if (angle >= bounds[2] && angle <= bounds[3]) {
      return 'M';
    }

    return 'F';
  }

  public void getsPulled() {
    // change to protected, will be called from update
    if (this.puller == null) { //should never come up, I hope
      return;
    }

    //PVector target = puller.coord.copy();
    //PVector target = new PVector(mouseX-width/2, mouseY-height/2);
    PVector target = puller.coord.copy();
    float angle = atan2( target.y-coord.y, target.x - coord.x );

    stroke(0, 125, 0);
    strokeWeight(1);

    PVector accl = (new PVector(cos(angle)*0.1, sin(angle)* 0.1));
    line(coord.x, coord.y, coord.x+accl.x*200, coord.y+accl.y*200);

    if (isPulled) {
      if (!centerCollide) {
        velocity.add(accl);
      } else {
        float magSquared = velocity.magSq();
        if ( magSquared > rmsq) {
          //println("magSquared is: "+magSquared+" rmsq: "+rmsq);
          velocity.mult(0.99);
        } else {
          isPulled = false;
          pullEdge.unHighlight();
          pullEdge = null;
          activeCount--;
        }
      }
    }

    if (this.getZone() == this.getType() && !centerCollide) { // really really need to fix this
      //println("this ran");
      // need a Convert function
      centerCollide = true;
      //this.velocity = new PVector(0,0);
    }
  }
}


//OOP city here we come, I didn't go to fancy programming school for nothing
class Potential extends Agent {
  static final float speed = 0.3;

  //Constructor 1 for debug
  public Potential(PVector inputCoord, PVector inputVel) {
    super(inputCoord, inputVel);
  }

  public Potential() {
    //Randomized constructor
    super(1, 2, speed);
    rmsq= sq(speed);
    potentials.add(this);
  }

  public Potential(Agent a) {
    super(a);
    rmsq = sq(speed) ;
    potentials.add(this);
  }

  public void checkLineCollision() {
    float angle = getAngle();

    Float hitObj = hitEval(angle, 1, 2);
    if (hitObj != null) {
      float hitAngle = hitObj;
      doCollision(hitAngle);
    }
  }

  public char getType() {
    return 'P';
  }
}

class Member extends Agent {
  static final float speed = 0.4;

  //Constructor 1 -- debug
  public Member(PVector inputCoord, PVector inputVel) {
    super(inputCoord, inputVel);
  }

  public Member() {
    //Randomized constructor
    super(2, 3, speed);
    members.add(this);
  }

  public Member(Agent p) {
    super(p);
    rmsq = sq(speed) ;
    members.add(this);
  }


  public void checkLineCollision() {
    // println("ran for agent" + this.toString());
    float angle = getAngle();

    Float hitObj = hitEval(angle, 2, 3);
    if (hitObj != null) {
      float hitAngle = hitObj;
      doCollision(hitAngle);
    }
  }

  public char getType() {
    return 'M';
  }
}

class Former extends Agent {
  static final float speed = 0.1;

  //Constructor 1 -- debug
  public Former(PVector inputCoord, PVector inputVel) {
    super(inputCoord, inputVel);
  }


  public Former() {
    //randomized constructor
    super(3, 1, speed);
    formers.add(this);
  }

  public Former(Agent a) {
    super(a);
    rmsq = sq(speed) ;
    formers.add(this);
  }

  public void checkLineCollision() {
    float angle = getAngle();

    Float hitObj = hitEval(angle, 3, 1);
    if (hitObj != null) {
      float hitAngle = hitObj;
      doCollision(hitAngle);
    }
  }



  public char getType() {
    return 'F';
  }
}

// Conversion functions. Note that these are not part of the
// Agent class. 
public Potential AtoP(Agent a) {
  agents.remove(a);
  formers.remove(a);
  Potential out = new Potential(a); // out will be added to potentials list automatically
  a = null;
  agents.add(out); 
  return out;
}

public Member AtoM(Agent a) {
  agents.remove(a);
  potentials.remove(a); // not sure if this works
  Member out = new Member(a);
  a = null;
  agents.add(out);
  return out;
}

public Former AtoF(Agent a) {
  agents.remove(a);
  members.remove(a);
  Former out = new Former(a);
  a = null; 
  agents.add(out);
  return out;
}
