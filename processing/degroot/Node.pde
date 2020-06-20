class Node {
  public static final int DI = 100; //circle diameter
  public static final int R = DI/2; 

  //fields
  // Note that the location of the node, (the center of each circle) is 
  // stored as a PVector
  PVector coord;
  float opinion;
  float oStar; // new opinion
  int number;



  public Node(float x_, float y_, float opinion_) {
    this.coord = new PVector (x_, y_);
    this.opinion = opinion_;
    this.number = counter_; 
    counter_ ++;
  }

  public void drawCircle() {
    float range = maxOp - minOp;
    float modif = 255 / range;
    //println("modif is " + modif+", range is "+range+" maxOp is "+maxOp+", minOp is "+minOp);

    float bg = 255-this.opinion*modif;
    // fill(255, 255, 34, bg); yellow
    //fill(255, 185, 135, bg);
    fill(bg);
    strokeWeight(2);
    stroke (0);
    ellipse(coord.x, coord.y, Node.DI, Node.DI);

    if (bg < 200) {
      fill(255);
    } else {
      fill(0);
    }
    //fill(0);

    text(this.opinion, coord.x-20, coord.y+7); 
    text("#"+this.number+":", coord.x-30, coord.y-7); //TODO FIX
  }

  public void updateOp() {
    this.opinion = this.oStar;
  }

  public void setOStar(float op_) {
    this.oStar = op_;
  }

  public float getOp() {
    return this.opinion;
  }

  public PVector getCoord() {
    return this.coord;
  }

  public void setCoord(PVector coord_) {
    this.coord = coord_;
  }
}
