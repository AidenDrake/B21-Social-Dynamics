public interface SpecialEdgeFactory {
  public Edge makeSpecialEdge(EdgeRecord er);
}

public class SpecialEdgeFactoryImpl implements SpecialEdgeFactory {
  // returns NULL if there's no edge to be made
  boolean thereIsPotential, thereIsMember, thereIsFormer;
  Agent a, b;

  public Edge  makeSpecialEdge(EdgeRecord er) throws NullPointerException {
    a = er.getA();
    b = er.getB();

    checkIfNull(a);
    checkIfNull(b);

    setBooleans();
    
    return makeAppropriateSpecialEdge(er);
  }

  private Edge makeAppropriateSpecialEdge(EdgeRecord er) {
    if (thereIsPotential && thereIsMember) {
      return memberPotentialEdgeFromSimpleEdge(er);
    } else if (thereIsMember && thereIsFormer) {
      return memberFormerEdgeFromSimpleEdge(er);
    } else {
      return null;
    }
  }

  private void checkIfNull(Agent agent) throws NullPointerException {
    if (agent == null) {
      throw new NullPointerException();
    }
  }

  private void setBooleans() {
    thereIsPotential = a instanceof Potential || b instanceof Potential;
    thereIsMember = a instanceof Member || b instanceof Member;
    thereIsFormer = a instanceof Former || b instanceof Former;
  }

  private MemberFormerEdge memberFormerEdgeFromSimpleEdge(EdgeRecord er) {
    Member m = er.getMember();
    Former f = er.getFormer();

    checkIfNull(m);
    checkIfNull(f);

    return new MemberFormerEdge(m, f);
  }

  private MemberPotentialEdge memberPotentialEdgeFromSimpleEdge(EdgeRecord er) {
    Potential p = er.getPotential();
    Member m = er.getMember();

    checkIfNull(m);
    checkIfNull(p);

    return new MemberPotentialEdge(m, p);
  }
}
