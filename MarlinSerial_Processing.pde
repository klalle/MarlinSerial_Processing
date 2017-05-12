import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port    
boolean readyForNext=false;
boolean First=true;
char serial_line_buffer[] = new char[100];

long CurrentLineNr =0;

String KeyboardString = "";
String NrCommandAndChecksum = null;
String incomingKeyboardString=null;
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

boolean keyispressed=false;
void draw()
{
  if(keyispressed){
    if(readyForNext){ //Wait for incomming "ok" before next move to not overload buffer
      EvaluateKey();
    }
  }
}

 void EvaluateKey(){
  if (key == CODED) {
    //println(keyCode);
    int Zspeed = 300; //mm/min
    int Zdistance=1;  //mm
    int XYspeed = 900;
    int XYdistance=1;
    
    readyForNext=false;

    if (keyCode == UP && moveInZ) {
      ApplyNrChecksumAndSend("G1 Z" + Zdistance + " F"+Zspeed);
    } else if (keyCode == DOWN && moveInZ) {
      ApplyNrChecksumAndSend("G1 Z-" + Zdistance + " F"+Zspeed);
    } else if (keyCode == UP) {
      ApplyNrChecksumAndSend("G1 Y" + XYdistance + " F"+XYspeed);
    } else if (keyCode == DOWN) {
      ApplyNrChecksumAndSend("G1 Y-" + XYdistance + " F"+XYspeed);
    } else if (keyCode == RIGHT) {
      ApplyNrChecksumAndSend("G1 X" + XYdistance + " F"+XYspeed);
    } else if (keyCode == LEFT) {
      ApplyNrChecksumAndSend("G1 X-" + XYdistance + " F"+XYspeed);
      
    }
    //delay the amount of time it takes for the axel to reach its position
    //Marlin answers with "ok" way before this happens which will casue lagg
    if(keyCode == UP && moveInZ){
      delay(1000*Zdistance/(Zspeed/60)); //[mm/(mm/s)]=[s]
    }else{
      delay(1000*XYdistance/(XYspeed/60));
    }
        
  }else if (key == 'z' ) {
    moveInZ = true; //
  }else if (key == 'y' ) {
    moveInZ = false; //
  }
  
 }

 void serialEvent(Serial myPort) {

      
  //if error occures, do not stop code...
  try {
    // get the Serial-ASCII string:
    incomingKeyboardString = myPort.readStringUntil('\n');

    if (incomingKeyboardString != null) {
       
      // trim off any whitespace before and after the data (if exists)
      incomingKeyboardString = trim(incomingKeyboardString);
      
      //println(incomingKeyboardString); //debug
      
      if(incomingKeyboardString.contains("ok")){
        readyForNext=true;
      }
    }
  }
  catch(RuntimeException e) {
    println(e);
  }

 }
 
 //Function that triggers when a key is pressed, that sends data to the Arduino over serial.
void keyPressed() {
  keyispressed=true;

}

void keyReleased() {
  keyispressed=false;
}