// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Pathfinding w/ Genetic Algorithms

// DNA is an array of vectors

class DNA {

  // The genetic sequence
  List<GPTree> genes;
  float minVal = 0;
  float maxVal = 10;

  // Constructor (makes a DNA of random PVectors)
  DNA(int depth) {
    
    genes = new ArrayList<GPTree>();
    //GPTree rootNode = new GPTree( null, new Terminal( "func" ) );
    //genes.add( rootNode );
    genes.addAll( randomTree( null, depth ) );
    // genes.get(0).printTree(" ");
    /*
    genes = new float[num];
    for (int i = 0; i < genes.length; i++) {
      genes[i] = random( minVal, maxVal );
    }
    */
  }

  // Constructor #2, creates the instance based on an existing array
  DNA(List<GPTree> newgenes) {
    // We could make a copy if necessary
    // genes = (PVector []) newgenes.clone();
    genes = newgenes;
  }

  // CROSSOVER
  // Creates new DNA sequence from two (this & and a partner)
  DNA crossover(DNA partner) {
    //println("crossover");
    
    
    //List<GPTree> parentGenesCopy = new ArrayList<GPTree>();
    // Pick a midpoints
    //int crossoverA = int( random( this.genes.size() ) );
    //int crossoverB = int( random( partner.genes.size() ) );
    
    // copy of parrent gene tree root node which makes a clone of all descedents in memory
    GPTree parentGenesRootNodeCopy = this.genes.get(0).clone();
    
    //println("parent copy");
    //parentGenesRootNodeCopy.printTree(" ");
    // get a copy of the parent genes
    List<GPTree> parentGenesCopy = parentGenesRootNodeCopy.buildListFromNode( new ArrayList<GPTree>() );
    int crossoverA = int( random(parentGenesCopy.size() ) );
    
    // copy of partner gene tree sub node which makes a clone of all descedents in memory
    int crossoverB = int( random( partner.genes.size() ) );
    GPTree partnerGenesSubNodeCopy = partner.genes.get(crossoverB).clone();
    //println("sub node copy");
    //partnerGenesSubNodeCopy.printTree(" ");
    
    //println("parent gene list",parentGenesCopy);
    //println("node at cross",parentGenesCopy.get(crossoverA));
    
    
    // get a copy of the parent genes
    List<GPTree> partnerSubNodeGenesCopy = partnerGenesSubNodeCopy.buildListFromNode( new ArrayList<GPTree>() );
    //println("crossoverA", crossoverA);
    // Splice in subtree
    if (crossoverA == 0) {
     //println("skipped");
     //println(partnerSubNodeGenesCopy.size());
     return new DNA(partnerSubNodeGenesCopy);
    } else {
      //println("cross A: ", crossoverA);
      //println(parentGenesCopy.get(crossoverA));
      //println(parentGenesCopy.get(crossoverA).getParentNode());
      parentGenesCopy.get(crossoverA).splice(partnerGenesSubNodeCopy);
      List<GPTree> newGenes = parentGenesCopy.get(0).buildListFromNode( new ArrayList<GPTree>() );
      //println("new");
      //println(newGenes.size());
      return new DNA(newGenes);
      
      
    }
    
    //return partner;
    
    // Take "half" from one and "half" from the other
    /*
    for (int i = 0; i < genes.length; i++) {
      if (i > crossover) child[i] = genes[i];
      else               child[i] = partner.genes[i];
    }    
    DNA newgenes = new DNA(child);
    return newgenes;
    */
    /*
    float[] child = new float[genes.length];
    // Pick a midpoint
    int crossover = int(random(genes.length));
    // Take "half" from one and "half" from the other
    for (int i = 0; i < genes.length; i++) {
      if (i > crossover) child[i] = genes[i];
      else               child[i] = partner.genes[i];
    }    
    DNA newgenes = new DNA(child);
    return newgenes;
    */
  }

  // Based on a mutation probability, picks a new random Vector
  void mutate(float m) {
    //println("mutate");
    /*
    for (int i = 0; i < genes.length; i++) {
      if (random(1) < m) {
        genes[i] = random( minVal, maxVal );
      }
    }
    */
  }
  
  List<GPTree> randomTree( GPTree parent, int depth ) {
    List<GPTree> newTree = new ArrayList<GPTree>();
    if ( depth == 0 ) {
      newTree.add( parent.addNewChild( parent, "leaf" ) );  // Terminal.getRandomLeaf();
    } else {
      // allocate a new parent
      GPTree newParentFunc;
      if ( parent == null ) {
        // must be root node so instatiate a new one
        newParentFunc = new GPTree( null, "func" );
      } else {
        // create a new node  with children, tied to the parent
        newParentFunc = parent.addNewChild( parent, "func" );
      }
      // add it to the ArrayList
      newTree.add( newParentFunc );
      
      for (int i = 0; i < 2; i++) { // all funcs have 2 arity for now
        // call method recursively for descendents
        newTree.addAll( randomTree( newParentFunc, depth - 1 ) );
      }
    }

    return newTree;
  }
  
}