public interface SpecialEdgeFactory {
  public Edge makeSpecialEdge(Edge e);
}

public class SpecialEdgeFactoryImpl implements SpecialEdgeFactory {
  public Edge  makeSpecialEdge(Edge e) throws NullPointerException {
    Agent a = e.getA();
    Agent b = e.getB();

    if (a == null || b == null) {
      throw new NullPointerException();
    }

    boolean thereIsPotential = a instanceof Potential || b instanceof Potential;
    boolean thereIsMember = a instanceof Member || b instanceof Member;
    boolean thereIsFormer = a instanceof Former || b instanceof Former;
    
    if (thereIsPotential && thereIsMember){
     // return new 
    }
  }
}
