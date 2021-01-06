/** //<>// //<>// //<>// //<>// //<>// //<>//
 * Agent for our ABM
 * 
 * 
 */

public static final float bounds[] = {0, PI/2, 7*PI/6, 11*PI/6};
//bounds[] is theta of lines 1, 2, & 3 respectively. The zero is a spacer.

public HashSet<Potential> potentials = new HashSet<Potential>();
public HashSet<Member> members = new HashSet<Member>();
public HashSet<Former> formers = new HashSet<Former>();

public AgentType potential, member, former;

static int counter = 1;

class Agent {
  // There's a set radius for all agents
  public static final float agentRadius = 2.5;
  static final float speed = 0.4;

  //Fields
  public PVector coord;
  PVector velocity;

  public Agent puller = null;
  boolean isPulled = false;
  boolean centerCollide = true;
  int index = counter;
  Edge pullEdge = null;
  boolean addBox = false;

  AgentType type;


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
  protected Agent(int lowerBoundIndex, int upperBoundIndex, float speed) { //TODO fix for new types, should be Agent(AgentType type)
    // Each subclass provides the Lower Bound Index and Upper Bound index
    // to specify the lines that they bounce off of. The speed is also set 
    // on a subclass basis. This function takes those parameters and makes 
    // an agent of the appropriate type.
    float theta;
    if (lowerBoundIndex > upperBoundIndex ) {
      // this is to handle formers. Bit of a messy fix.
      theta = random((2*PI-bounds[3]), bounds[1]);
    } else {
      theta = random(bounds[lowerBoundIndex], bounds[upperBoundIndex]);
    }  

    // generate a random distance from center,
    // and a random angle from center to randomly place the agent.
    float dist = random(10, (bigRadius - 10));
    coord = new PVector (dist*cos(theta), dist*sin(theta)); 
    velocity = PVector.random2D().mult(speed);

    this.index = counter++;
  }


  //Public methods
  public void update() {
    if (isPulled) {
      this.getsPulled();
    }
    this.checkOuterWallCollision();

    if (this.centerCollide) {
      this.checkLineCollision();
    }
    coord.add(velocity);
  }

  public void display() {
    if (addBox) {
      //draw a box around the agent
      fill(255);
      strokeWeight(1);
      stroke(0);
      rect(coord.x, coord.y, 10, 10);
    }
    noStroke();
    fill(0);
    ellipse(coord.x, coord.y, agentRadius*2, agentRadius*2);

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


  public void checkOuterWallCollision() {
    // Collisions against the "outer wall" of the big circle
    // Correction vector procedure adapted from the processing "Collisions" example

    final PVector center = new PVector(0, 0);

    //vector distance to center
    PVector centerDistanceVect = PVector.sub(coord, center);

    //magnitude of distance to center
    float distanceToCenter = centerDistanceVect.mag();

    //Maximum distance before touching edge
    float maxDist = bigRadius-agentRadius;

    if (distanceToCenter > maxDist) {
      // if collision with outside

      //Calculate correction vector, which scoots the agent back inside the circle
      float correction = (distanceToCenter - maxDist) / 2.0;
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
    return Objects.hash(this.index, "Agent");
  }

  public void checkLineCollision() {
    float angle = getAngle();

    Float hitObj = evaluateCollision(angle, type.lowerbound, type.upperbound); 
    if (hitObj != null) {
      float hitAngle = hitObj;
      doCollision(hitAngle);
    }
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
    int mod = flip ? -2 : 2;

    PVector out = velocopy.add(white.mult(mod));

    return out ;
  }

  protected Float evaluateCollision(float angle, int lowerIndex, int upperIndex) {
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
    PVector target = new PVector();
    if (this.puller == null) {
      if (this.getType() == 'P') {
        target = new PVector(random(-400, -300), random(300, 400));
      }
      if (this.getType() == 'F') {
        target = new PVector(random(300, 400), random(300, 400));
      }
    } else {
      target = puller.coord.copy();
    }

    stroke(0, 125, 0);
    strokeWeight(1);


    if (isPulled) {
      if (!centerCollide) {
        PVector distance = target.sub(coord);
        PVector accl = distance.mult(0.001);
        velocity.add(accl);
      } else {
        float magSquared = velocity.magSq();
        float restingSpeed = speed * speed; 
        if ( magSquared > restingSpeed) {
          velocity.mult(0.94);
        } else {
          // once we get in the right quadrent
          isPulled = false;
          if (pullEdge != null) {
            active.remove(pullEdge);
            pullEdge.unHighlight();
            pullEdge = null;
            puller = null;
          } else {
            this.addBox = false;
          }
          activeCount--; //<>//
        }
      }
    }

    if (this.getZone() == this.getType() && !centerCollide) { // really really need to fix this
      // need a Convert function
      centerCollide = true;
    }
  }
}


//OOP city here we come, I didn't go to fancy programming school for nothing
class AgentType {
  float speed;
  int upperbound, lowerbound; // should be final in the subclasses
  char abbv;

  public AgentType(float speed, int lowerbound, int upperbound, char abbv) {
    this.upperbound = upperbound;
    this.lowerbound = lowerbound;
    this.speed = speed;
    this.abbv = abbv;
  }

  @Override
    public String toString() { // replaces "get Type"
    return ""+abbv;
  }

  @Override
    public boolean equals(Object obj) {
    if (!(obj instanceof AgentType)) {
      return false;
    } else {
      return (this.toString() == obj.toString()); //quality programming
    }
  }
}

void initAgentTypes() {
  //here's where we hardcode a bunch of values. Not the end of the world
  potential = new AgentType(0.3, 1, 2, 'P'); // not sure if lower/upper is perfect
  member = new AgentType(0.4, 2, 3, 'M');
  former = new AgentType(0.1, 3, 1, 'F');
}


// Conversion functions. Note that these are not part of the
// Agent class. 
public Potential AtoP(Agent a) {
  formers.remove(a);
  // change a's type, probably add to Pontentials list here
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

public void AtoF(Agent a) {
  agents.remove(a);
  members.remove(a);
  a = new Former(a);
  agents.add(a);
  //formers.add(a) ?? not sure if I should add this
}

public void defect(Former f) {
  AtoP(f);
  defectMain(f);
}

public void defect(Member m) {
  AtoF(m);
  defectMain(m);
}

private void defectMain(Agent a) {
  a.addBox = true;
  a.isPulled = true;
  a.centerCollide = false;
  activeCount++;
}

Agent randomAgent() {
  //
  int index = int(random(0, agents.size()));
  Iterator<Agent> iter = agents.iterator();
  for (int j = 0; j < index - 1; j++) {
    iter.next();
  }
  Agent out = iter.next();
  //

  return out;
}
