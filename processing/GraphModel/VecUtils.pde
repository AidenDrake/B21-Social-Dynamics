// File for my Vector utility functions

  static public PVector proj(PVector a, PVector b) {
    // returns the vector projection of b onto a.
    // in use, a should be the normalized perpen
    float aMag = a.mag();
    float aDotb =a.dot(b);
    float temp = (aDotb / (aMag*aMag));
    PVector out = a.mult(temp);
    return out;
  }

  static PVector getPerpen(PVector a) {
    return new PVector(a.y, -a.x);
  }

  
