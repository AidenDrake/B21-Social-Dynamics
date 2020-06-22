/**
 * Recursive tree program that's meant to be a testing enviroment for controlP5
 *
 * CP5 bang for reset, CP5 radio (or toggle?) for run
 *
 */
import controlP5.*;

int tlevel = 0;
int j = 0;
boolean anim;
float[] radialPos = new float[2];
float k = 0;

ControlP5 cp5;
Slider2D s;

void setup() {
  size(500, 500);
  anim = true;
  background(0);

  cp5 = new ControlP5(this);
  
  s = cp5.addSlider2D("tree tilt").setPosition(30, 40)
    .setSize(100, 100).setArrayValue(new float[] {50, 50});

  cp5.addBang("reset")
    .setPosition(200, 40)
    .setSize(40, 40)
    .setId(1)
    ;

  cp5.addBang("grow")
    .setPosition(280, 40)
    .setSize(40, 40)
    .setId(1)
    ;
    
    cp5.addToggle("anim").setPosition(340, 40).setSize(50, 20);
}

void draw() {
  background(0);
  stroke(255);
  strokeWeight(2);
  textSize(16);
  //float clockDisplay = s.getArrayValue()[0];
  //float widderDisplay= s.getArrayValue()[1];
  //text("c disp: "+clockDisplay+"  w disp: "+widderDisplay, 250, 50);
  pushMatrix();
  tree(250, 500, 70, 0, tlevel%10 ); //max 10 levels
  popMatrix();

  if (keyPressed && (key == ' ')) {
    if (j > 20) {
      tlevel++;
      j = 0;
    } else {
      j++;
    }
  } else {
    j=21;
  }

  if (anim) {
    radialPos[0] = 50 + (sin(radians(k)))*30;
    radialPos[1] = 50 + (cos(radians(k)))*30;
    ++k;
    s.setArrayValue(radialPos);
  }
  // s.setArrayValue(new float[] {25, 70}); //interesting
}

public void reset() {
  tlevel = 0;
}

public void grow() {
  tlevel++;
}

void tree(float rootX, float rootY, float longness, int i, int max) {
  float clockwise = map(s.getArrayValue()[0], 0, 100, 0, PI);
  float widdershins = map(s.getArrayValue()[1], 0, 100, -PI, 0);
  translate(rootX, rootY);
  line(0, 0, 0, -longness);
  translate(0, -longness);
  pushMatrix();
  //rotate(2*PI/10);
  rotate(clockwise);
  if (i<max) {
    tree(0, 0, longness*0.9, i+1, max);
  }
  popMatrix();
  pushMatrix();
  //rotate(-2*PI/10);
  rotate(widdershins);
  if (i<max) {
    tree(0, 0, longness*0.9, i+1, max);
  }
  popMatrix();
}
