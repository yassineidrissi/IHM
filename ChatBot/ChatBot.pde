import java.io.*;
import java.net.*;

void setup() {
  googleTTS("Hello world", "en");
  exit();
}

void googleTTS(String txt, String language) {
  try {
    // Encode the text for the URL
    String encoded = URLEncoder.encode(txt, "UTF-8");

    // Build the URL
    String urlString = "http://translate.google.com/translate_tts"
      + "?ie=UTF-8"
      + "&q=" + encoded
      + "&tl=" + language
      + "&client=tw-ob";  // "tw-ob" trick

    URL url = new URL(urlString);
    URLConnection connection = url.openConnection();

    // Use a modern User-Agent to avoid 403/429
    connection.setRequestProperty("User-Agent", "Mozilla/5.0");
    connection.connect();

    // Read the response
    InputStream is = connection.getInputStream();
    File f = new File(sketchPath() + "/" + txt + ".mp3");
    FileOutputStream out = new FileOutputStream(f);

    byte[] buffer = new byte[1024];
    int len;
    while ((len = is.read(buffer)) > 0) {
      out.write(buffer, 0, len);
    }
    out.close();
    is.close();

    println("File created: " + txt + ".mp3");
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
