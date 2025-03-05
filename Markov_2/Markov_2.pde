// Code for the Markov Chain analysis of a gesture in Processing

ArrayList<PVector> points = new ArrayList<PVector>();
boolean recording = false;

void setup() {
  size(600, 600);
  background(255);
  stroke(0);
  strokeWeight(2);
  println("Draw a gesture by clicking and dragging. Release to analyze the Markov chain.");
}

void draw() {
  // Record and draw the gesture while the mouse is pressed
  if (recording) {
    PVector p = new PVector(mouseX, mouseY);
    points.add(p);
    if (points.size() > 1) {
      PVector prev = points.get(points.size()-2);
      line(prev.x, prev.y, p.x, p.y);
    }
  }
}

void mousePressed() {
  // Reset canvas and gesture data
  background(255);
  points.clear();
  recording = true;
}

void mouseReleased() {
  recording = false;
  
  if (points.size() > 1) {
    // ---- Freeman Chain Code ----
    // Convert the gesture into a sequence of 8-direction codes
    ArrayList<Integer> chainCode = new ArrayList<Integer>();
    for (int i = 1; i < points.size(); i++) {
      PVector prev = points.get(i-1);
      PVector curr = points.get(i);
      float angle = atan2(curr.y - prev.y, curr.x - prev.x);
      if (angle < 0) angle += TWO_PI; // normalize angle between 0 and TWO_PI
      // Divide the circle into 8 equal sectors (each PI/4 radians)
      int direction = round(angle / (PI/4)) % 8;
      chainCode.add(direction);
    }
    println("Freeman Chain Code: " + chainCode);
    
    // ---- Markov Chain Transition Matrix ----
    // Create an 8x8 matrix for 8 possible states (directions)
    int[][] transitions = new int[8][8];
    for (int i = 0; i < chainCode.size() - 1; i++) {
      int current = chainCode.get(i);
      int next = chainCode.get(i+1);
      transitions[current][next]++;
    }
    
    // Print the transition matrix
    println("Transition Matrix:");
    for (int i = 0; i < 8; i++) {
      print("From state " + i + ": ");
      for (int j = 0; j < 8; j++) {
        print(transitions[i][j] + " ");
      }
      println();
    }
    
    // ---- Compute Transition Probabilities ----
    // Analyze transitions from the last observed state
    int lastState = chainCode.get(chainCode.size()-1);
    int totalTransitions = 0;
    for (int j = 0; j < 8; j++) {
      totalTransitions += transitions[lastState][j];
    }
    if (totalTransitions > 0) {
      println("Transition probabilities from last state " + lastState + ":");
      for (int j = 0; j < 8; j++) {
        float prob = (float)transitions[lastState][j] / totalTransitions;
        println("To state " + j + ": " + nf(prob, 1, 2));
      }
    } else {
      println("No transitions recorded from the last state.");
    }
  }
}
