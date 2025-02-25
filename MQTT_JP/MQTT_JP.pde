import processing.data.*;

PVector startPos, endPos;
float startTime, endTime;
boolean firstClicked = false;
float speed = 0;
ArrayList<Float> speeds = new ArrayList<Float>();
ArrayList<Float> times = new ArrayList<Float>(); // Stores time taken for each movement
Table table;

float meanSpeed = 0;
float variance = 0;
float stdDev = 0;
float amplitude = 0;
boolean gaussCalculated = false;

void setup() {
  size(800, 600);
  table = new Table();
  table.addColumn("time");
  table.addColumn("speed");
}

void draw() {
  background(240);

  // Draw objects (circles)
  fill(255, 0, 0);
  ellipse(200, 300, 50, 50); // First object
  fill(0, 0, 255);
  ellipse(600, 300, 50, 50); // Second object

  // Display information
  fill(0);
  textSize(16);
  text("Position: (" + mouseX + ", " + mouseY + ")", 10, 20);
  text("Speed: " + nf(speed, 0, 2) + " px/sec", 10, 40);
  text("Mean Speed: " + nf(meanSpeed, 0, 2), 10, 60);
  text("Std Dev: " + nf(stdDev, 0, 2), 10, 80);
  text("Amplitude: " + nf(amplitude, 0, 6), 10, 100);

  // Draw Gaussian curve if calculated
  if (gaussCalculated) {
    drawGaussian();
  }

  // Draw speed points over time
  drawSpeedTimeGraph();
}

void mousePressed() {
  if (dist(mouseX, mouseY, 200, 300) < 25) { 
    startPos = new PVector(mouseX, mouseY);
    startTime = millis();
    firstClicked = true;
  } 
  else if (dist(mouseX, mouseY, 600, 300) < 25 && firstClicked) { 
    endPos = new PVector(mouseX, mouseY);
    endTime = millis();
    calculateSpeed();
    firstClicked = false;
  }
}

void calculateSpeed() {
  float distance = dist(startPos.x, startPos.y, endPos.x, endPos.y);
  float elapsedTime = (endTime - startTime) / 1000.0;
  if (elapsedTime > 0) {
    speed = distance / elapsedTime;
    speeds.add(speed);
    times.add(elapsedTime);

    // Store in CSV table
    TableRow newRow = table.addRow();
    newRow.setFloat("time", elapsedTime);
    newRow.setFloat("speed", speed);
  }
}

void keyPressed() {
  if (key == 's') {
    saveTable(table, "data.csv");
    println("Data saved to data.csv");
  } else if (key == 'c') {
    calculateGaussian();
    gaussCalculated = true;
  }
}

void calculateGaussian() {
  if (speeds.size() > 0) {
    // Mean speed
    meanSpeed = 0;
    for (float s : speeds) {
      meanSpeed += s;
    }
    meanSpeed /= speeds.size();

    // Variance
    variance = 0;
    for (float s : speeds) {
      variance += pow(s - meanSpeed, 2);
    }
    variance /= speeds.size();

    // Standard deviation
    stdDev = sqrt(variance);

    // Amplitude calculation
    amplitude = 1 / (stdDev * sqrt(2 * PI));
  } else {
    println("No data recorded. Click on the objects.");
  }
}

void drawGaussian() {
  stroke(0, 0, 255);
  noFill();
  beginShape();
  for (int i = 0; i < width; i++) {
    float x = map(i, 0, width, meanSpeed - 3 * stdDev, meanSpeed + 3 * stdDev);
    float y = amplitude * exp(-pow((x - meanSpeed), 2) / (2 * pow(stdDev, 2)));
    float screenY = map(y, 0, amplitude, height - 50, height / 2);
    vertex(i, screenY);
  }
  endShape();

  // Draw recorded speeds as dots on the Gaussian curve
  fill(255, 0, 0);
  for (int i = 0; i < speeds.size(); i++) {
    float x = map(speeds.get(i), meanSpeed - 3 * stdDev, meanSpeed + 3 * stdDev, 0, width);
    float y = amplitude * exp(-pow((speeds.get(i) - meanSpeed), 2) / (2 * pow(stdDev, 2)));
    float screenY = map(y, 0, amplitude, height - 50, height / 2);
    ellipse(x, screenY, 5, 5); // Plot recorded speeds
  }
}
float[] toFloatArray(ArrayList<Float> list) {
  float[] array = new float[list.size()];
  for (int i = 0; i < list.size(); i++) {
    array[i] = list.get(i);
  }
  return array;
}
void drawSpeedTimeGraph() {
  stroke(0);
  fill(0);
  textSize(14);
  text("Speed vs Time Graph", 550, 20);

  stroke(0);
  line(500, 100, 500, 300); // Y-axis
  line(500, 300, 750, 300); // X-axis

  // Label axes
  text("Time (s)", 720, 320);
  text("Speed (px/s)", 480, 100);

  // Plot data points
  fill(255, 0, 0);
  for (int i = 0; i < times.size(); i++) {
    float x = map(times.get(i), 0, max(toFloatArray(times)), 500, 750);

float y = map(speeds.get(i), 0, max(toFloatArray(speeds)), 300, 100);

    ellipse(x, y, 5, 5);
  }
}
