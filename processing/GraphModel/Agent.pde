/** //<>// //<>// //<>// //<>// //<>// //<>//
 * Agent for our ABM
 * 
 * 
 */

public static final float bounds[] = {0, PI/2, 7*PI/6, 11*PI/6};
//bounds[] is theta of lines 1, 2, & 3 respectively. The zero is a spacer.

public HashSet<Agent> potentials = new HashSet<Agent>(); 
//we don't have insurance that members will never end up in the formers list, since these are all agents
//we'll have to mantain the lists seperately, (and we can also implement some checks.)
public HashSet<Agent> members = new HashSet<Agent>();
public HashSet<Agent> formers = new HashSet<Agent>();

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

  // ***VERY IMPORTANT*** - Main constructor
  protected Agent(AgentType type) {
    // Each type provides the Lower Bound Index and Upper Bound index
    // to specify the lines that they bounce off of. The speed is also set 
    // on a type basis.
    
    this.type = type;
    
    float theta;
    if (type.lowerbound > type.upperbound ) {
      // this is to handle formers. Bad fix. NOTE hardcoded values. 
      theta = random((2*PI-bounds[3]), bounds[1]);
    } else {
      theta = random(bounds[type.lowerbound], bounds[type.upperbound]);
    }  

    // generate a random distance from center,
    // and a random angle from center to randomly place the agent.
    float dist = random(10, (bigRadius - 10));
    coord = new PVector (dist*cos(theta), dist*sin(theta)); 
    velocity = PVector.random2D().mult(speed);

    this.index = counter++;
    
    this.addToTypeSet();
    agents.add(this);
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

  public boolean isType (AgentType t) {
    return this.type.equals(t);
  }

  @Override
    public String toString() {
    return (this.type + " #"+ index);
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
    //will be called from update
    // we should make it so that target isn't repeatedly set.
    PVector target = new PVector();
   println(this.puller == null);
    if (this.puller == null) {
      // this is a case for defections.
      if (this.type.equals(potential)) {
        target = new PVector(random(-400, -300), random(300, 400));
      }
      if (this.type.equals(former)) {
        target = new PVector(random(300, 400), random(300, 400));
      }
    } else {
      target = puller.coord.copy();
    }

    stroke(0, 125, 0); //<>//
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
          activeCount--;
        }
      }
    }
    
    if (("" + this.getZone()).equals(this.type.toString()) && !centerCollide) {
      //toString is a cludgy fix to match the char output produced by getZone
      // this runs a lot for some reason, but I don't think that's a problem
      centerCollide = true;
    }
  }

  private void removeFromTypeSet() {
    this.type.set.remove(this);
  }

  private void addToTypeSet() {
    this.type.set.add(this);
  }

  public void toType(AgentType t) {
    this.removeFromTypeSet();
    this.type = t;
    this.addToTypeSet();
  }

  public void defectTo(AgentType t) {
    this.toType(t);
    this.defectEffects();
  }

  private void defectEffects() {
    this.addBox = true;
    this.isPulled = true;
    this.centerCollide = false;
    activeCount++;
  }
}


class AgentType {
  // these should all be associated with certain lists as well. 
  float speed;
  public int upperbound, lowerbound; // should be final in the subclasses
  char abbv;
  public HashSet<Agent> set;

  public AgentType(float speed, int lowerbound, int upperbound, char abbv, HashSet<Agent> set) {
    this.upperbound = upperbound;
    this.lowerbound = lowerbound;
    this.speed = speed;
    this.abbv = abbv;
    this.set = set;
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
      return (this.toString().equals(obj.toString())); //quality programming
    }
  }
}

void initAgentTypes() {
  //here's where we hardcode a bunch of values. Not the end of the world
  potential = new AgentType(0.3, 1, 2, 'P', potentials); // not sure if lower/upper is perfect
  member = new AgentType(0.4, 2, 3, 'M', members);
  former = new AgentType(0.1, 3, 1, 'F', formers);
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
