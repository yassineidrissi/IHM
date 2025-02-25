// Importer la bibliothèque MQTT (assurez-vous de l'avoir installée via le plugin processing-mqtt)
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

// Définir l'adresse du broker MQTT et créer un identifiant client unique
String broker = "tcp://broker.hivemq.com:1883"; // Vous pouvez changer pour votre broker local ou utiliser shiftr.io
String clientId = "ProcessingClient_" + int(random(1000,9999));
MqttClient client;

// Variable pour stocker les données reçues (ici, la température)
String receivedTemperature = "";

void setup() {
  size(800, 600);
  background(200);
  
  try {
    // Créer le client MQTT avec une persistance en mémoire
    client = new MqttClient(broker, clientId, new MemoryPersistence());
    
    // Options de connexion : ici, on choisit une session propre
    MqttConnectOptions connOpts = new MqttConnectOptions();
    connOpts.setCleanSession(true);
    
    println("Connexion au broker : " + broker);
    client.connect(connOpts);
    println("Connecté !");
    
    // Passer à l'étape suivante : définir le callback pour gérer les événements MQTT
    setupCallback();
    
    // S'abonner à un topic (par exemple, pour recevoir les températures)
    client.subscribe("masterSIC/temperature");
    println("Abonné au topic : masterSIC/temperature");
    
    // Publier un message test pour simuler l'envoi d'une température sur un autre topic
    publishTestMessage();
    
  } catch (MqttException me) {
    println("Erreur MQTT : " + me.getMessage());
  }
}

void setupCallback() {
  client.setCallback(new MqttCallback() {
    // Si la connexion est perdue, afficher le message d'erreur
    public void connectionLost(Throwable cause) {
      println("Connexion perdue : " + cause.getMessage());
    }
    
    // Lorsque un message arrive, le traiter selon le topic
    public void messageArrived(String topic, MqttMessage message) throws Exception {
      String msg = new String(message.getPayload());
      println("Message reçu sur le topic " + topic + " : " + msg);
      
      // Si le message concerne la température, l'enregistrer dans notre variable
      if (topic.equals("masterSIC/temperature")) {
        receivedTemperature = msg;
      }
    }
    
    // Indique que la livraison d'un message est complétée
    public void deliveryComplete(IMqttDeliveryToken token) {
      println("Livraison complétée.");
    }
  });
}

void publishTestMessage() {
  try {
    // Simuler une température aléatoire entre 20 et 30
    String testTemp = " " + int(random(20, 30));
    MqttMessage message = new MqttMessage(testTemp.getBytes());
    message.setQos(1);  // QoS niveau 1 : au moins une fois
    
    // Publier le message sur le topic "masterSIC/temperature" 
    // (le même topic auquel vous êtes abonné)
    client.publish("masterSIC/temperature", message);
    println("Message publié sur masterSIC/temperature : " + testTemp);
  } catch (MqttException me) {
    println("Erreur lors de la publication : " + me.getMessage());
  }
}


void draw() {
  background(200);
  fill(0);
  textSize(20);
  // Afficher la température reçue (mise à jour via le callback)
text("Température reçue : " + receivedTemperature, 50, height/2);
}
