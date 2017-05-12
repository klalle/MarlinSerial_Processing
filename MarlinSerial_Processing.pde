import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port    
boolean ready;
boolean First=true;
char serial_line_buffer[] = new char[100];

long CurrentLineNr =0;

String KeyboardString = "";
String NrCommandAndChecksum = null;

boolean moveInZ = false;

//Function that adds checksum to current command
void ApplyNrChecksumAndSend(String commandStr){
  
  //Start by adding the line nr to the command:
  CurrentLineNr++; //Increment line nr
  commandStr = "N" + CurrentLineNr + " " + commandStr;
  
  //Convert string to char array
  serial_line_buffer = commandStr.toCharArray();
  
  byte checksum = 0, count = 0;
  //Calc checksum of char array:
  while (count<commandStr.length()){
    checksum ^= serial_line_buffer[count++]; //This is the magic checksum 
  }
  
  //Add checksum
  NrCommandAndChecksum=commandStr + "*" + checksum + "\n";
  println(NrCommandAndChecksum);
  
  //Send to Marlin: 
  myPort.write(NrCommandAndChecksum);
}


void setup()
{
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 250000);
  delay(10000);
  //Start by resetting the line number counter to N1
  ApplyNrChecksumAndSend("M110");
  
  ApplyNrChecksumAndSend("G91");
  
  
}

  
void draw()
{
  
}

void serialEvent(Serial myPort) {

      String incomingKeyboardString=null;
      //if error occures, do not stop code...
      try {
        // get the Serial-ASCII string:
        incomingKeyboardString = myPort.readStringUntil('\n');

        if (incomingKeyboardString != null) {
           println(incomingKeyboardString); //debug
          // trim off any whitespace before and after the data (if exists)
          incomingKeyboardString = trim(incomingKeyboardString);
  
            
        }
    }
    catch(RuntimeException e) {
      println(e);
    }

 }
 
 //Function that triggers when a key is pressed, that sends data to the Arduino over serial.
void keyPressed() {
  // If the return key is pressed, do something with it
  //println(key);
  if (key == CODED) {
    //println(keyCode);
    
    if (keyCode == UP && moveInZ) {
      ApplyNrChecksumAndSend("G1 Z1 F300");
    } else if (keyCode == DOWN && moveInZ) {
      ApplyNrChecksumAndSend("G1 Z-1 F300");
    } else if (keyCode == UP) {
      ApplyNrChecksumAndSend("G1 Y1 F600");
    } else if (keyCode == DOWN) {
      ApplyNrChecksumAndSend("G1 Y-1 F600");
    } else if (keyCode == RIGHT) {
      ApplyNrChecksumAndSend("G1 X1 F600");
    } else if (keyCode == LEFT) {
      ApplyNrChecksumAndSend("G1 X-1 F600");
    } 
  }else if (key == 'z' ) {
    moveInZ = true; //
  }else if (key == 'y' ) {
    moveInZ = false; //
  }
}