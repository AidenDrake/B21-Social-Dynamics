public interface EdgeFactory {
  public Edge makeEdge();
}

public class EdgeFactoryImpl implements EdgeFactory {
  boolean thereIsPotential, thereIsMember, thereIsFormer;
  Agent a, b;
  EdgeRecord er;

  public EdgeFactoryImpl(EdgeRecord _er) {
    a = er.getA();
    b = er.getB();
    er = _er;
    setBooleans();
  }

  public Edge  makeEdge() throws NullPointerException {
    checkIfNull(a);
    checkIfNull(b);
    
    return makeAppropriateEdge(er);
  }

  private Edge makeAppropriateEdge(EdgeRecord er) {
    if (thereIsPotential && thereIsMember) {
      return memberPotentialEdgeFromSimpleEdge(er);
    } else if (thereIsMember && thereIsFormer) {
      return memberFormerEdgeFromSimpleEdge(er);
    } else {
      return new Edge(er);
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
