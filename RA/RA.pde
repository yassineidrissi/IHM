// Importer les bibliothèques nécessaires
import java.io.*;                     // Pour la fonction loadPatternFilenames()
import processing.opengl.*;            // Pour le rendu OPENGL
import jp.nyatla.nyar4psg.*;           // Bibliothèque NyARToolkit pour Processing

// Définir les chemins (à adapter sur votre machine)
String camPara = "C:/VotreChemin/Processing/libraries/nyar4psg/data/camera_para.dat";
String patternPath = "C:/VotreChemin/Processing/libraries/nyar4psg/patternMaker/examples/ARToolKit_Patterns";

// Dimensions de l'AR (la détection se fera sur une image de cette taille)
int arWidth = 1280;
int arHeight = 720;
// Nombre de marqueurs à charger (par exemple, les 10 premiers fichiers .patt)
int numMarkers = 10;

// Déclaration des variables globales pour AR
MultiMarker nya;
float displayScale;                  // Pour ajuster l'affichage à la taille de la fenêtre
color[] colors = new color[numMarkers]; // Couleurs aléatoires pour les objets
float[] scaler = new float[numMarkers]; // Facteurs de mise à l'échelle pour chaque objet

// Pour cet exemple, nous utilisons une image statique (input.jpg) pour la détection
PImage input, inputSmall;

void setup() {
  // Taille de la fenêtre avec le rendu OPENGL
  size(1280, 720, OPENGL);
  
  // Créer une police pour l'affichage des coordonnées (optionnel)
  textFont(createFont("Arial", 80));
  
  // Charger l'image d'entrée (placez "input.jpg" dans le dossier data de votre sketch)
  input = loadImage("input.jpg");
  // Faire une copie redimensionnée pour la détection AR
  inputSmall = input.get();
  inputSmall.resize(arWidth, arHeight);
  
  // Calculer le facteur d'échelle pour adapter l'image AR à la fenêtre du sketch
  displayScale = (float) width / arWidth;
  
  // Initialiser NyARToolkit pour la détection
  // Les paramètres sont : contexte, largeur, hauteur, fichier de calibration, configuration par défaut
  // Au lieu de NyAR4PsgConfig.CONFIG_DEFAULT :
  nya = new MultiMarker(this, arWidth, arHeight, camPara, NyAR4PsgConfig.CONFIG_PSG);
  // Pour un retour immédiat en cas de perte de marqueur
  nya.setLostDelay(1);
  
  // Charger la liste des fichiers .patt depuis le dossier patternPath
  String[] patterns = loadPatternFilenames(patternPath);
  
  // Pour chaque marqueur à utiliser (ici, numMarkers), on définit une couleur et un facteur d'échelle
  for (int i = 0; i < numMarkers; i++){
    colors[i] = color(random(255), random(255), random(255), 160);
    scaler[i] = random(0.5, 1.9);
    // Optionnel : si vous souhaitez ajouter des marqueurs à la détection, vous pouvez appeler ici :
    // nya.addARMarker(patternPath + "/" + patterns[i], 80);
    // Dans cet exemple basique, on se concentre sur la détection via l'image déjà chargée.
  }
}

void draw() {
  // Effacer le fond
  background(0);
  // Afficher l'image d'entrée sur toute la fenêtre
  image(input, 0, 0, width, height);
  
  // Lancer la détection sur l'image redimensionnée
  nya.detect(inputSmall);
  
  // Dessiner les repères (coordonnées) des marqueurs détectés en 2D
  drawMarkers();
  
  // Dessiner des boîtes 3D sur les marqueurs détectés
  drawBoxes();
}

// Fonction pour dessiner les coordonnées 2D des coins des marqueurs
void drawMarkers() {
  // Mettre le texte en petite taille pour afficher les coordonnées
  textAlign(LEFT, TOP);
  textSize(10);
  noStroke();
  
  // Adapter l'échelle des coordonnées AR à la taille de la fenêtre
  scale(displayScale);
  
  // Pour chaque marqueur...
  for (int i = 0; i < numMarkers; i++) {
    // Si le marqueur i n'est pas détecté, passer au suivant
    if (!nya.isExistMarker(i)) continue;
    
    // Récupérer les 4 sommets du marqueur sous forme de PVector
    PVector[] pos2d = nya.getMarkerVertex2D(i);
    // Pour chacun des 4 coins, afficher ses coordonnées
    for (int j = 0; j < pos2d.length; j++){
      String s = "("+nf(pos2d[j].x,1,1)+", "+nf(pos2d[j].y,1,1)+")";
      fill(255);
      rect(pos2d[j].x, pos2d[j].y, textWidth(s) + 3, textAscent() + textDescent() + 3);
      fill(0);
      text(s, pos2d[j].x + 2, pos2d[j].y + 2);
      // Dessiner un petit point rouge
      fill(255, 0, 0);
      ellipse(pos2d[j].x, pos2d[j].y, 5, 5);
    }
  }
}

// Fonction pour dessiner une boîte 3D sur chaque marqueur détecté
void drawBoxes() {
  // Appliquer la perspective AR (même point de vue pour tous les marqueurs)
  nya.setARPerspective();
  
  // Pour chaque marqueur...
  for (int i = 0; i < numMarkers; i++){
    if (!nya.isExistMarker(i)) continue;
    
    // Sauvegarder la matrice de transformation
    pushMatrix();
    
    // Appliquer la transformation associée au marqueur i
    // Récupérer la matrice du marqueur et l’appliquer dans Processing
    setMatrix(nya.getMarkerMatrix(i));

    // Inverser l'axe Y pour que l'affichage soit cohérent avec Processing
    scale(1, -1);
    // Appliquer le facteur d'échelle spécifique à ce marqueur
    scale(scaler[i]);
    
    // Dessiner une boîte (cube) de côté 40 (les dimensions sont en mm)
    noStroke();
    fill(colors[i]);
    box(40);
    
    // Restaurer la matrice d'origine
    popMatrix();
  }
}

// Fonction utilitaire pour charger la liste des fichiers .patt à partir d'un dossier
String[] loadPatternFilenames(String path) {
  File folder = new File(path);
  FilenameFilter pattFilter = new FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".patt");
    }
  };
  return folder.list(pattFilter);
}
