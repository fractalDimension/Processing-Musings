import java.util.List;

public class NodeFunction implements Cloneable {
  private String termType;
  private String[] funcArray = {"add", "sub"};
  private String[] leafArray = {"vector", "neighbors", "randomVec"};
  private PVector leafVector;

   
  public NodeFunction( String termType ){
    
    if ( termType == "func") {
      this.termType = getRandomFunction();
    } else { // TODO check if leaf and then do something else
      this.termType = getRandomLeaf();
      this.leafVector = PVector.random2D();
    }
  }
  
  /*
  public Terminal( String termType, int val ){
    this.termType = termType;
    this.floatVal = val;
  }
  */
  
  /*
  public String[] getFuncArray() {
    return this.funcArray;
  }

  public String[] getLeafArray() {
    return this.leafArray;
  }
  */
  
  public NodeFunction clone()  {
     try {
        NodeFunction nodeFunctionCopy = (NodeFunction) super.clone();
        nodeFunctionCopy.termType = termType;
        nodeFunctionCopy.funcArray = funcArray;
        nodeFunctionCopy.leafArray = leafArray;
        if (leafVector != null ) {
          nodeFunctionCopy.leafVector = leafVector.copy();
        }
        
        return nodeFunctionCopy;
     } catch (CloneNotSupportedException e)
     {
        throw new AssertionError(e);
     }
       
  }

  public String getRandomFunction() {
    int randIndex  = int( random( this.funcArray.length ) );
    return this.funcArray[randIndex];
  }
  public String getRandomLeaf() {
    int randIndex  = int( random( this.leafArray.length ) );
    return this.leafArray[randIndex];
  }
   
  public String getType() {
    return this.termType;
  }
   
  public PVector add(PVector a, PVector b) {
    return PVector.add(a, b);
  }
   
  public PVector sub(PVector a, PVector b) {
    return PVector.sub(a, b);
  }
   
  public PVector getVector() {
    return this.leafVector.copy();
  }
  
  public PVector getRandVec() {
    // println("used rand");
    return PVector.random2D();
  }
  
  public PVector getVectorFromNeighbors( PVector[] neighbors ) {
    
    PVector newCurrent = new PVector( 0.0, 0.0) ;
    for( int i = 0; i < neighbors.length; i++ ) {
      // add the neighbor scaled by the genes
      newCurrent.add( neighbors[i] );
    }
    newCurrent.normalize();
    return newCurrent;
  }
  
   
  public PVector evalNodeFunction ( GPTree tree, PVector[] neighbors ){
    if ( tree.getNodeFunction().getType() == "add" ){
      // add each child
      List<GPTree> children = tree.getChildrenNodes();
      return add( evalNodeFunction(children.get(0), neighbors), evalNodeFunction(children.get(1), neighbors) );
    } else if ( tree.getNodeFunction().getType() == "sub" ) {
      // subtract each child
      List<GPTree> children = tree.getChildrenNodes();
      return sub( evalNodeFunction(children.get(0), neighbors), evalNodeFunction(children.get(1), neighbors) );
    } else if (tree.getNodeFunction().getType() == "vector") {
      // return vector leaf
      return tree.getNodeFunction().getVector();
    } else if ( tree.getNodeFunction().getType() == "randomVec" ) {
      return tree.getNodeFunction().getRandVec();
    } else {
      return tree.getNodeFunction().getVectorFromNeighbors( neighbors );
    }
  }
}