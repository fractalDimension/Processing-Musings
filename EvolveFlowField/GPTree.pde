import java.util.ArrayList;
import java.util.List;
 
public class GPTree implements Cloneable {
  private String id;
  private List<GPTree> children = new ArrayList();
  private GPTree parent;
  private String nodeType;
  private NodeFunction nodeFunc;
  //private PVector leafVector;
    
  public GPTree(GPTree parent, String nodeType ) {
    this.parent = parent;
    this.nodeType = nodeType;
    this.nodeFunc = new NodeFunction( nodeType );
  }
  
  // copy cons
  
    
  public String getId() {
    println("get id");
    
    return id;
  }
   
  public NodeFunction getNodeFunction() {
    return nodeFunc;
  }
    
  public void setId(String id) {
    this.id = id;
  }
    
  public List<GPTree> getChildrenNodes() {
    return children;
  }
  
  public void splice ( GPTree nodeToSpliceIn ) {
    List<GPTree> parentsChildren = this.getParentNode().getChildrenNodes();
    //GPTree parentNode = this.getParentNode();//.getChildren();
    //println("parent node: ", parentNode);
    
    for ( GPTree child: parentsChildren ) {
      if ( child == this ) {
        parentsChildren.remove(child);
        break;
      }
    }
    parentsChildren.add(nodeToSpliceIn);
    this.parent = null;
    
  }
  
  public void setParentNode( GPTree parent ) {
    //println("parent set to: ", parent);
    this.parent = parent;
    //println("actual parent", this.parent);
    
  }
    
  public GPTree getParentNode() {
    //println("get parent this",this);
    //println("this.parent ",this.parent);
    return parent;
  }
  
  // pass in empty list when using outside of this class
  public List<GPTree> buildListFromNode( List<GPTree> inputList ) {
    //GPTree thisNode = this.clone();
    inputList.add(this);
    for (GPTree child: this.getChildrenNodes() ) {
      // GPTree childCopy = child.clone();
      child.buildListFromNode( inputList );
    }
    return inputList;
  }
  
  public GPTree clone()  {
     try {
        GPTree treeCopy = (GPTree) super.clone();
        
        //println("treecopy: ", treeCopy);
        //println("treecopy parent: ", treeCopy.getParentNode());
        treeCopy.parent = null;
        
        //println("treecopy parent null: ", treeCopy.getParentNode());
        treeCopy.nodeFunc = nodeFunc.clone();
        treeCopy.children = new ArrayList<GPTree>(children.size());
        for (GPTree child: children) {
          
          //println("child of treecopy id: ", treeCopy);
          GPTree childCopy = child.clone();
          treeCopy.children.add(childCopy);
          childCopy.setParentNode(treeCopy);
           
           //println("child, parent: ", child, child.getParentNode());
        }
        return treeCopy;
     } catch (CloneNotSupportedException e)
     {
        throw new AssertionError(e);
     }
       
  }
   
 
  public GPTree addNewChild(GPTree parent, String nodeType) { 
    GPTree tree = new GPTree(parent, nodeType);
    //tree.setId(id);
    parent.getChildrenNodes().add(tree); // TODO might have to addAll
    return tree;
   }
   
   public void printTree(String appender, int level) {
     String gap = new String(new char[level]).replace("\0", appender);
     println( gap + this.nodeFunc.getType());
    for (GPTree each : this.getChildrenNodes()) {
      each.printTree(appender, level + 1);
    }
   }

}