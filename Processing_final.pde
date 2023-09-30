import processing.serial.*;
import controlP5.*;
import java.util.*;

ControlP5 cp5;

Serial myPort; // The serial port
boolean newData = false;
boolean printimage = false;
float xPos = 1; // horizontal position of the graph 
float xPos2 = 1;
float step = 40;
float step2 = 8;
//Variables to draw a continuous line.
float lastxPos = 1;
float lastxPos2 = 1;
float lastheight = 0;
float lastheight2 = 0;
float lastheight3 = 0;
int n =0;

float startTime;


ArrayList<float[]> inByteList;




void setup() {
   // set the window size:
   inByteList = new ArrayList<>();
   size(1000, 500);
   frameRate(1000);
   surface.setResizable(false);
   cp5 = new ControlP5(this);
   // Get the list of available serial ports
   String[] portList = Serial.list();
   // Add the serial port options to the dropdown menu
   cp5.addScrollableList("dropdown")
      .setPosition(0, 0)
      .setSize(100, 100)
      .setBarHeight(20)
      .setItemHeight(20)
      .addItems(Arrays.asList(portList));

   smooth(4);

   // add the button 
     cp5.addButton("Export")
     .setValue(0)
     .setPosition(101,0)
     .setSize(100,20)
     ;

   // A serialEvent() is generated when a newline character is received :
   background(0xff); // set inital background:
   //initialize grid
   stroke(255, 140, 140);
   strokeWeight(1);
   for (int k = 0; k <= width / step2; k++) {
      line(k * step2, 0, k * step2, height);
      line(0, k * step2, width, k * step2);
   } 
   strokeWeight(2);
   for (int k = 0; k <= width / step; k++) {
      line(k * step, 0, k * step, height);
      line(0, k * step, width, k * step);
   }
   startTime = millis();
}
void draw() {
   // if (newData) {
   if(inByteList.size() > 0){

      float[] inByte = inByteList.get(0);
      inByteList.remove(0);
if (inByte != null) {
      int inByteLength = countNonZeroElements(inByte);

      switch (inByteLength) {
      case 1:
         stroke(0, 0, 0); //stroke color
         strokeWeight(1); //stroke wide
         line(lastxPos, lastheight, xPos, height - inByte[0]);
         lastxPos = xPos;
         lastheight = int(height - inByte[0]);
         
         break;
      case 2:
         stroke(0, 0, 0); //stroke color
         strokeWeight(1); //stroke wide
         line(lastxPos, lastheight, xPos, height - inByte[0]);
         stroke(0,0, 0); //stroke color
         strokeWeight(1);
         line(lastxPos, lastheight2, xPos, height - inByte[1]);
         lastxPos = xPos;
         lastheight = int(height - inByte[0]);
         lastheight2 = int(height - inByte[1]);

         break;
      case 3:
         stroke(0, 0, 0); //stroke color
         strokeWeight(1); 
         line(lastxPos, lastheight, xPos, height - inByte[0]);
         stroke(0, 0, 0); //stroke color
         strokeWeight(1);
         line(lastxPos, lastheight2, xPos, height - inByte[1]);
         stroke(0, 0, 0); //stroke color
         strokeWeight(1);
         line(lastxPos, lastheight3, xPos, height - inByte[2]);
         lastxPos = xPos;
         lastheight = int(height - inByte[0]);
         lastheight2 = int(height - inByte[1]);
         lastheight3 = int(height - inByte[2]);

         break;
      }
      // at the edge of the window, go back to the beginning:
      if (xPos >= width) {
        if(printimage == true){
        String fileName = "Rekaman_" + year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".png";
        saveFrame(fileName);}
    
         xPos = 0;
         lastxPos = 0;
         background(0xff); //Clear the screen.
         stroke(255, 140, 140);
         strokeWeight(1);
         for (int k = 0; k <= width / step2; k++) {
            line(k * step2, 0, k * step2, height);
            line(0, k * step2, width, k * step2);
         }
         strokeWeight(2);
         for (int k = 0; k <= width / step; k++) {
            line(k * step, 0, k * step, height);
            line(0, k * step, width, k * step);
         }
      } else {
        
        if(inByteLength==1){
         // increment the horizontal position: 1000 = 0.3
         xPos = xPos + 0.5;}
         else {
         xPos = xPos + 1;}
      }
   }
   }
   
}


void serialEvent(Serial myPort) {
   // get the ASCII string:
   String inString = myPort.readStringUntil('\n');
   if (inString != null) {
      inString = trim(inString); // trim off whitespaces.
      String[] inString2 = split(inString, ',');
      float[] inByte = new float[inString2.length];
      
      // rambahan is used to control the position of where to plot.
      int[] tambahan = {
         350,
         200,
         100
      };
      

      for (int i = 0; i < inString2.length; i++) {
         inByte[i] = float(inString2[i]);
      }

     // Ad8232 data is ranged from 400 to 900 change the ("map(inbyte,W,X,Y,Z)") change the W , X , Y ,Z based on sensor output.
      // convert to a number.
      for (int i = 0; i < inString2.length; i++) {
         inByte[i] = (map(inByte[i], 0, 200, 0, 120)) + tambahan[i]; //map to the screen height. 
      }
  //    dataPoints++;
      inByteList.add(inByte);
   }
}


void dropdown(int n) {
   String selectedPort = cp5.get(ScrollableList.class, "dropdown").getItem(n).get("name").toString();

   if (myPort != null && myPort.active()) {
      myPort.stop();
   }

   myPort = new Serial(this, selectedPort,9600);
   //myPort.bufferUntil('\n');

   background(255);
   stroke(255, 140, 140);
   strokeWeight(1);
   for (int k = 0; k <= width / step2; k++) {
      line(k * step2, 0, k * step2, height);
      line(0, k * step2, width, k * step2);
   }
   strokeWeight(2);
   for (int k = 0; k <= width / step; k++) {
      line(k * step, 0, k * step, height);
      line(0, k * step, width, k * step);
   }
}


public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
  n = 0;
}

public void Export(int theValue) {
  printimage = true;
}


int countNonZeroElements(float[] array) {
   int count = 0;
   for(float element : array){
      if (element != 0.0f) {
            count++;
      }
   }
   return count;
}