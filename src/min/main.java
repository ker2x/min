package min;

import min.lang.MinObject;
import min.lang.Message;
//import min.lang.Method;
import min.lang.File;
import min.lang.Bootstrap;
//import java.util.ArrayList;

public class main {
  public static void main(String[] args) throws Exception {
    String code = null;
    String file = "<eval>";
    boolean debug = false;
    
    for (int i = 0; i < args.length; i++) {
      if (args[i].equals("-e")) code = args[++i];
      else if (args[i].equals("-d")) debug = true;
      else if (args[i].equals("-h")) usage();
      else code = File.read(file = args[i]);
    }
    
    if (code == null) {
      usage();
    }

    new Bootstrap().run();
    Message message = Message.parse(code, file);
    if (debug) System.out.println(message.fullName());
    message.evalOn(MinObject.lobby);
  }

  public static void usage() {
    System.out.println("usage: min [-d] < -e code | file.min >");
    System.exit(1);
  }

}