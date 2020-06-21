/**
 * Recursive tree program that's meant to be a testing enviroment for controlP5
 */
import controlP5.*;

int count = 0;
int j = 0;

ControlP5 cp5;
Slider2D s;

void setup() {
  size(500, 500);
  background(0);
  cp5 = new ControlP5(this);
  s = cp5.addSlider2D("tree tilt").setPosition(30,40)
  .setSize(100,100).setArrayValue(new float[] {50,50});
  smooth();
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
  tree(250, 500, 70, 0, count%10 ); //max 10 levels
  popMatrix();

  if (keyPressed && (key == ' ')) {
    if (j > 20) {
      count++;
      j = 0;
    } else {
      j++;
    }
  }
  else {
    j=21;
  }
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
