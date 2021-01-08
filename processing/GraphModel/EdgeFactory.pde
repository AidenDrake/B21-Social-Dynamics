public interface EdgeFactory {
  public Edge makeEdge();
}

public class EdgeFactoryImpl implements EdgeFactory {
  boolean thereIsPotential, thereIsMember, thereIsFormer;
  Agent a, b;
  EdgeRecord er;

  public EdgeFactoryImpl(EdgeRecord _er) {
    er = _er;

    a = er.getA();
    b = er.getB();
    setBooleans();
  }

  public Edge  makeEdge() throws NullPointerException {
    checkIfNull(a);
    checkIfNull(b);
    setBooleans();

    Edge temp = this.er.edge;

    boolean tempHighlight = (temp == null) ? false : temp.highlight;
    if (tempHighlight) {
      println("tempHighlight" + tempHighlight);
    }

    //println("temp " + temp);

    Edge newEdge = makeAppropriateEdge(er);

    newEdge.highlight= tempHighlight;

    return newEdge;
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
    thereIsPotential = a.isType(potential) || b.isType(potential);
    thereIsMember = a.isType(member) || b.isType(member);
    thereIsFormer = a.isType(former) || b.isType(former);
  }

  private MemberFormerEdge memberFormerEdgeFromSimpleEdge(EdgeRecord er) {
    Agent m = er.getType(member);
    Agent f = er.getType(former);

    checkIfNull(m);
    checkIfNull(f);

    return new MemberFormerEdge(m, f);
  }

  private MemberPotentialEdge memberPotentialEdgeFromSimpleEdge(EdgeRecord er) {
    Agent p = er.getType(potential);
    Agent m = er.getType(member);

    checkIfNull(m);
    checkIfNull(p);

    return new MemberPotentialEdge(m, p);
  }
}
