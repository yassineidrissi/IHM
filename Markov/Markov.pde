// List to store mouse coordinates
ArrayList<PVector> points = new ArrayList<PVector>();
boolean recording = false;

void setup() {
  size(600, 600);
  background(255);
  stroke(0);
  strokeWeight(2);
  println("Draw a gesture by clicking and dragging. Release to analyze.");
}

void draw() {
  // While the mouse is pressed, record and draw the points
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
  // Reset canvas and data
  background(255);
  points.clear();
  recording = true;
}

void mouseReleased() {
  recording = false;
  // Further processing happens here...
  // ---- Amplitude Analysis ----
float minX = width, maxX = 0, minY = height, maxY = 0;
  for (PVector p : points) {
    if (p.x < minX) minX = p.x;
    if (p.x > maxX) maxX = p.x;
    if (p.y < minY) minY = p.y;
    if (p.y > maxY) maxY = p.y;
  }
  float amplitudeX = maxX - minX;
  float amplitudeY = maxY - minY;
  println("Amplitude X: " + amplitudeX + " | Amplitude Y: " + amplitudeY);
    // ---- Histogram Analysis ----
  // Compute distances between successive points as a basic histogram proxy.
  ArrayList<Float> distances = new ArrayList<Float>();
  for (int i = 1; i < points.size(); i++) {
    float d = dist(points.get(i-1).x, points.get(i-1).y, points.get(i).x, points.get(i).y);
    distances.add(d);
  }
  float sum = 0;
  for (float d : distances) {
    sum += d;
  }
  float meanDistance = sum / distances.size();
  println("Mean distance between points: " + meanDistance);
  // ---- Freeman Chain Code ----
// Quantize directions into 8 possible values (0 to 7)
ArrayList<Integer> chainCode = new ArrayList<Integer>();MarkovMarkov
for (int i = 1; i < points.size(); i++) {
  PVector prev = points.get(i-1);
  PVector curr = points.get(i);
  float angle = atan2(curr.y - prev.y, curr.x - prev.x);
  if (angle < 0) angle += TWO_PI; // normalize angle between 0 and TWO_PI
  // Divide the circle into 8 sectors (each PI/4 radians)
  int direction = round(angle / (PI/4)) % 8;
  chainCode.add(direction);
}
println("Freeman Chain Code: " + chainCode);



}
