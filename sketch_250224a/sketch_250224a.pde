// Listes pour stocker les vitesses et les temps associés
ArrayList<Float> speeds = new ArrayList<Float>();
ArrayList<Float> times = new ArrayList<Float>();

// Variables pour la dernière position et le dernier instant
float lastX, lastY;
float lastTime;
float currentSpeed;

void setup() {
  size(800, 600);
  // Initialisation avec la position initiale de la souris et l'instant courant
  lastX = mouseX;
  lastY = mouseY;
  lastTime = millis();
  background(240);
}

void draw() {
  background(240);
  float currentTime = millis();
  float dt = currentTime - lastTime;
  
  // Calcul de la distance parcourue par la souris depuis le dernier frame
  float dx = mouseX - lastX;
  float dy = mouseY - lastY;
  
  // Calcul de la vitesse (pixels par milliseconde)
  if (dt > 0) {
    currentSpeed = dist(mouseX, mouseY, lastX, lastY) / dt;
    // Stocker les données
    speeds.add(currentSpeed);
    times.add(currentTime);
  }
  
  // Mise à jour des variables pour la prochaine itération
  lastX = mouseX;
  lastY = mouseY;
  lastTime = currentTime;
  
  // Affichage de la vitesse courante
  fill(0);
  textSize(16);
  text("Vitesse: " + nf(currentSpeed,1,3) + " px/ms", 10, 20);
  
  // Optionnel : tracer la courbe de vitesse en fonction du temps
  stroke(0);
  noFill();
  beginShape();
  for (int i = 0; i < speeds.size(); i++) {
    float t = times.get(i);
    float s = speeds.get(i);
    // Mappage du temps et de la vitesse sur l'écran
    float x = map(t, times.get(0), currentTime, 0, width);
    float y = map(s, 0, getMaxSpeed(), height, 0);
    vertex(x, y);
  }
  endShape();
  
  // Calcul et affichage des paramètres de la "fonction gaussienne" si des données sont présentes
  if (speeds.size() > 0) {
    // Amplitude : la vitesse maximale observée
    float amplitude = getMaxSpeed();
    
    // Recherche du temps correspondant à la vitesse maximale (centre du pic)
    int idxMax = 0;
    for (int i = 0; i < speeds.size(); i++) {
      if (speeds.get(i) == amplitude) {
        idxMax = i;
        break;
      }
    }
    float tCenter = times.get(idxMax);
    
    // Calcul du temps moyen pondéré par la vitesse
    float sumWeights = 0;
    float weightedTime = 0;
    for (int i = 0; i < speeds.size(); i++){
      sumWeights += speeds.get(i);
      weightedTime += speeds.get(i) * times.get(i);
    }
    float meanTime = weightedTime / sumWeights;
    
    // Calcul de la variance pondérée (l'étalement autour du temps moyen)
    float varianceSum = 0;
    for (int i = 0; i < speeds.size(); i++){
      varianceSum += speeds.get(i) * sq(times.get(i) - meanTime);
    }
    float variance = varianceSum / sumWeights;
    
    // Affichage des paramètres
    fill(0);
    text("Amplitude (vitesse max): " + nf(amplitude,1,3), 10, 40);
    text("Centre (temps max): " + nf(tCenter,1,3) + " ms", 10, 60);
    text("Variance: " + nf(variance,1,3), 10, 80);
  }
}

// Fonction pour obtenir la vitesse maximale enregistrée
float getMaxSpeed() {
  float maxSpeed = 0;
  for (float s : speeds) {
    if (s > maxSpeed) {
      maxSpeed = s;
    }
  }
  return maxSpeed;
}
