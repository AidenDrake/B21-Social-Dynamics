public interface SpecialEdgeFactory {
  public Edge makeSpecialEdge(Edge e);
}

public class SpecialEdgeFactoryImpl implements SpecialEdgeFactory {
  boolean thereIsPotential, thereIsMember, thereIsFormer;
  Agent a, b;

  public Edge  makeSpecialEdge(Edge e) throws NullPointerException {
    a = e.getA();
    b = e.getB();

    checkIfNull(a);
    checkIfNull(b);

    setBooleans();

    if (thereIsPotential && thereIsMember) {
      return memberPotentialEdgeFromSimpleEdge(e);
    } else if (thereIsMember && thereIsFormer) {
      return memberFormerEdgeFromSimpleEdge(e);
    } else {
      throw new ArithmeticException("makeSpecialEdge called with wrong values");
    }
  }

  private void checkIfNull(Agent a) throws NullPointerException {
    if (a == null) {
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

    checkIfNull(m);
    checkIfNull(f);

    return new MemberFormerEdge(m, f);
  }

  private MemberPotentialEdge memberPotentialEdgeFromSimpleEdge(Edge e) {
    Potential p = e.getPotential();
    Member m = e.getMember();

    checkIfNull(m);
    checkIfNull(p);

    return new MemberPotentialEdge(m, p);
  }
}
