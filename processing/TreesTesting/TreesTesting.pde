int count = 0;
int j = 0;

void setup(){
  size(500, 500);
  background(0);
}

void draw(){
  background(0);
  stroke(255);
  strokeWeight(2);
  pushMatrix();
  tree(250, 500, 70, 0, count%14 );
  popMatrix();
  
  if (keyPressed && (key == ' ')){
    if (j > 20){
    count++;
    j = 0;
    }
    else{
      j++;
    }
  }
}

void tree(float rootX, float rootY, float longness, int i, int max){
  translate(rootX, rootY);
  line(0, 0, 0, -longness);
  translate(0, -longness);
  pushMatrix();
  rotate(2*PI/10);
  if (i<max){
    tree(0, 0, longness*0.9, i+1, max);
  }
  popMatrix();
  pushMatrix();
  rotate(-2*PI/10);
  if (i<max){
    tree(0, 0, longness*0.9, i+1, max);
  }
  popMatrix();
}
