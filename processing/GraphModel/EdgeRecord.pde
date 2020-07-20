public class EdgeRecord {

  //fields
  Agent a, b;
  Edge specialEdge, drawEdge;

  public EdgeRecord(Agent inputA, Agent inputB) {
    this.a = inputA;
    this.b = inputB;
  }

  public Member getMember() {
    if (a instanceof Member) {
      return (Member) a;
    } else if (b instanceof Member) {
      return (Member) b;
    } else {
      return null;
    }
  }

  public Potential getPotential() {
    if (a instanceof Potential) {
      return (Potential) a;
    } else if (b instanceof Potential) {
      return (Potential) b;
    } else {
      return null;
    }
  }

  public Former getFormer() {
    if (a instanceof Former) {
      return (Former) a;
    } else if (b instanceof Former) {
      return (Former) b;
    } else {
      return null;
    }
  }
  
   public Agent getA(){
    return this.a;
  }
  
  public Agent getB(){
    return this.b;
  }
}

public class EdgeRecordStorage {
}
