import java.util.Arrays;

// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Pathfinding w/ Genetic Algorithms

// Rocket class -- this is just like our Boid / Particle class
// the only difference is that it has DNA & fitness

class Rocket {

  // All of our physics stuff
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float recordDist;
  PVector[][] vectorMemory;
  int[] lastCheckedGrid;
  
  float fitness;
  DNA dna;
  
  // Could make this part of DNA??)
  float maxspeed = 6.0;
  float maxforce = 1.0;

  boolean stopped;  // Am I stuck?
  boolean dead; // Did I hit an obstacle?
  
  int finish;       // What was my finish? (first, second, etc. . . )

  //constructor
  Rocket(PVector l, DNA dna_) {
    acceleration = new PVector();
    velocity = new PVector();
    position = l.copy();
    vectorMemory = new PVector[width / GRID_SCALE][height / GRID_SCALE];
    r = 2;
    dna = dna_;
    stopped = false;
    finish = 100000;  // Some high number to begin with
    recordDist = width;
  }

  // FITNESS FUNCTION 
  // distance = distance from target
  // finish = what order did i finish (first, second, etc. . .)
  // f(distance,finish) =   (1.0f / finish^1.5) * (1.0f / distance^6);
  // a lower finish is rewarded (exponentially) and/or shorter distance to target (exponetially)
  void calcFitness() {
    float d = recordDist;
    if (d < diam/2) {
      d = 1.0;
    }
    // Reward finishing faster and getting closer
    fitness = (1.0f / pow(finish,1.5)) * (1 / (pow(d,6)));
    
    //if (dead) fitness = 0;
  }

  void setFinish(int f) {
    finish = f;
  }

  // Run in relation to all the obstacles
  // If I'm stuck, don't bother updating or checking for intersection
  void run(ArrayList<Obstacle> o) {
    if (!stopped) {
      update();
      // If I hit an edge or an obstacle
      if ((borders()) || (obstacles(o))) {
        stopped = true;
        dead = true;
      }
    }
    // Draw me!
    display();
  }

   // Did I hit an edge?
   boolean borders() {
    if ((position.x < 0) || (position.y < 0) || (position.x > width) || (position.y > height)) {
      return true;
    } else {
      return false;
    }
  }

  // Did I make it to the target?
  boolean finished() {
    float d = dist(position.x,position.y,target.r.x,target.r.y);
    if (d < recordDist) {
      recordDist = d;
    }
    if (target.contains(position)) {
      stopped = true;
      return true;
    }
    return false;
  }

  // Did I hit an obstacle?
  boolean obstacles(ArrayList<Obstacle> o) {
    for (Obstacle obs : o) {
      if (obs.contains(position)) {
        return true;
      }
    }
    return false;
  }
  
  void modifyVectorMemory( int x_, int y_, PVector velocity_ ) {
    // USE GENES HERE
    
    // perception section
    PVector[] neighbors = getNeighbors( x_, y_ );
    
    // if current cell is empty give myself a random one
    // this might not work well...
    if ( vectorMemory[x_][y_] == null ) {
      
      vectorMemory[x_][y_] = this.dna.genes.get(0).getNodeFunction().evalNodeFunction( this.dna.genes.get(0), neighbors );// PVector.random2D(); // arbitrary for now
    }
    
    int[] currentGrid = new int[]{x_, y_};
    
    // dont reprocess if set and haven't left grid
    if ( !Arrays.equals( lastCheckedGrid, currentGrid) ) {
      //set the last checked grid to the current one
      lastCheckedGrid = new int[]{x_, y_};
      
      
      
      /*
      // PVector newCurrent = new PVector(0,0);
      PVector newCurrent = PVector.random2D();
      
      for( int i = 0; i < dna.genes.length; i++ ) {
        // add the neighbor scaled by the genes
        newCurrent.add( neighbors[i].mult( dna.genes[i] ) );
      }
      */
      // next two lines are ugly. Need to refactor for how methods will be called
      NodeFunction rootNodeTerminal = this.dna.genes.get(0).getNodeFunction();
      PVector newCurrent = rootNodeTerminal.evalNodeFunction(this.dna.genes.get(0), neighbors);
      
      newCurrent.normalize();
      vectorMemory[x_][y_] = newCurrent.copy();
    }
    

    // velocity_ use me some how
    /*
    if ( vectorMemory[x_][y_] == null ) {
      
      vectorMemory[x_][y_] = PVector.random2D(); // arbitrary for now
    }
    */
  }
  
  
  PVector[] getNeighbors( int x_, int y_ ) {
    PVector[] neighbors = new PVector[NEIGHBORHOOD];
    
    // loop thru neighborhood starting top left
    int index = 0;
    for (int yoff = -HALF_WIN; yoff <= HALF_WIN; yoff++) {
      int k = y_ + yoff;
      for (int xoff = -HALF_WIN; xoff <= HALF_WIN; xoff++) {
        int i = x_ + xoff;
        // check to see if out of bounds
        if ( i < 0 || k < 0 || i >= COLS || k >= ROWS) {
          
          neighbors[index] = new PVector(0, 0); // could be smarter about what value this is, maybe return null
          index++;
        } else {
          // else get the value
          if ( vectorMemory[x_][y_] == null ) {
            neighbors[index] = new PVector(0, 0); // TODO need better representation for empty neighbor
          } else {
            neighbors[index] = vectorMemory[x_][y_].copy();
          }
          index++;
        }  
      }
    }
    
    return neighbors;
  }

  void update() {
    if (!finished()) {
      // Where are we?  Our position will tell us what steering vector to look up in our DNA;
      int x = (int) position.x/GRID_SCALE;
      int y = (int) position.y/GRID_SCALE;
      x = constrain(x,0,width/GRID_SCALE-1);  // Make sure we are not off the edge
      y = constrain(y,0,height/GRID_SCALE-1); // Make sure we are not off the edge

      // Get the steering vector out of our genes in the right spot
      // A little Reynolds steering here
      modifyVectorMemory( x, y, velocity ); // TODO provide more inputs
      // PVector desired = dna.genes[x+y*(width/gridscale)].get();
      PVector desired = vectorMemory[x][y].copy();// get a copy of desired from memory
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired,velocity);
      acceleration.add(steer);
      acceleration.limit(maxforce);
      
      velocity.add(acceleration);
      velocity.limit(maxspeed);
      position.add(velocity);
      acceleration.mult(0);
    }
  }

  void display() {
    //fill(0,150);
    //stroke(0);
    //ellipse(position.x,position.y,r,r);
    float theta = velocity.heading() + PI/2;
    fill(200,100);
    stroke(0);
    pushMatrix();
    translate(position.x,position.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }
  
  void highlight() {
    stroke(0);
    line(position.x,position.y,target.r.x,target.r.y);
    fill(255,0,0,100);
    ellipse(position.x,position.y,16,16);
 
  }
  
  void debugDraw() {
    int cols = width / GRID_SCALE;
    int rows = height / GRID_SCALE;
    for (int i = 0; i < cols; i++) {
      for (int k = 0; k < rows; k++) {
        if ( vectorMemory[i][k] != null ) {
          drawVector( vectorMemory[i][k], i*GRID_SCALE, k*GRID_SCALE, GRID_SCALE-2);
        }
      }
    }
  }
  
  // Renders a vector object 'v' as an arrow and a position 'x,y'
  void drawVector(PVector v, float x, float y, float scayl) {
    pushMatrix();
    // Translate to position to render vector
    translate(x+GRID_SCALE/2,y);
    stroke(0,100);
    // Call vector heading function to get direction (note that pointing up is a heading of 0) and rotate
    rotate(v.heading());
    // Calculate length of vector & scale it to be bigger or smaller if necessary
    float len = v.mag()*scayl;
    // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
    //drawArrow(len);
    line(-len/2,0,len/2,0); // line instead if arrow is too busy
    
    popMatrix();
  }
  
  void drawArrow(float len) {
    line(0,0,len, 0);
    line(len, 0, len - 1, -1);
    line(len, 0, len - 1, 1);
  }

  float getFitness() {
    return fitness;
  }

  DNA getDNA() {
    return dna;
  }

  boolean stopped() {
    return stopped;
  }

}