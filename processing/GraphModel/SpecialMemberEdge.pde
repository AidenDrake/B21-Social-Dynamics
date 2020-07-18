public interface SpecialEdgeFactory {
  public Edge makeSpecialEdge(Edge e);
}

public class SpecialEdgeFactoryImpl implements SpecialEdgeFactory {
  boolean thereIsPotential, thereIsMember, thereIsFormer;

  public Edge  makeSpecialEdge(Edge e) throws NullPointerException {
    Agent a = e.getA();
    Agent b = e.getB();

    checkIfNull(a, b);

    setBooleans();

    if (thereIsPotential && thereIsMember) {
      return memberPotentialEdgeFromSimpleEdge(e);
    }

    else if (thereIsMember && thereIsFormer) {
      return memberFormerEdgeFromSimpleEdge(e);
    }
    
    else{
      //TODO throw new error!! fin
    }
  }

  private void checkIfNull throws NullPointerException(Agent a, Agent b) {
    if (a == null || b == null) {
      throw new NullPointerException();
    }
  }

  private void setBooleans() {
    thereIsPotential = a instanceof Potential || b instanceof Potential;
    thereIsMember = a instanceof Member || b instanceof Member;
    thereIsFormer = a instanceof Former || b instanceof Former;
  }

  private MemberFormerEdge memberFormerEdgeFromSimpleEdge(Edge e) {
    Member m = e.getMember();
    Former f = e.getFormer();
    checkIfNull(m, f);
    return new MemberFormerEdge(m, f);
  }

  private MemberPotentialEdgeFromSimpleEdge(Edge e) {
    Potential p = e.getPotential();
    Member m = e.getMember();
    checkIfNull(m, p);
    return new MemberPotentialEdge(m, p);
  }
}
