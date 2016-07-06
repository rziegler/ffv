/**
 * a simple attractor
 *
 * MOUSE
 * left click, drag  : attract nodes
 *
 * KEYS
 * r                 : reset nodes
 * s                 : save png
 */
import generativedesign.*;
import java.util.Calendar;

Flight flight;

int xCount; // number of prices per flight
int yCount; // number of flights
float gridSize = 500;

// nodes array 
Node[] myNodes;

// attractor
Attractor myAttractor;


// image output
boolean saveOneFrame = false;



void setup() {  
  flight = new Flight(); //<>//
  flight.init();
  
  xCount = flight.priceDevelopments.get(0).prices.size(); //<>//
  yCount = flight.priceDevelopments.size();
  
  myNodes =  new Node[xCount*yCount];
  
  size(1200, 900);  //<>//

  // setup drawing parameters
  colorMode(RGB, 255, 255, 255, 100);
  smooth();
  noStroke();

  background(255); 

  cursor(CROSS);

  // setup node grid
  initGrid();
  
  

  // setup attractor
  myAttractor = new Attractor(0, 0);
}

void draw() {
  fill(255, 10);
  rect(0, 0, width, height);

  myAttractor.x = mouseX;
  myAttractor.y = mouseY;

  for (int i = 0; i < myNodes.length; i++) {
    if (mousePressed) {
      myAttractor.attract(myNodes[i]);
    }

    myNodes[i].update();

    // draw nodes
    fill(0);
    rect(myNodes[i].x, myNodes[i].y, 1, 1);
  }

  // image output
  if (saveOneFrame == true) {
    saveFrame("_M_4_1_02_"+timestamp()+".png");
    saveOneFrame = false;
  }
}


void initGrid() {
  int i = 0; 
  for (int y = 0; y < yCount; y++) {
    for (int x = 0; x < xCount; x++) {
      float xPos = x*(gridSize/(xCount-1))+(width-gridSize)/2; //<>//
      float yPos = y*(gridSize/(yCount-1))+(height-gridSize)/2;
      myNodes[i] = new Node(xPos, yPos);
      myNodes[i].setBoundary(0, 0, width, height);
      myNodes[i].setDamping(1.0);  //// 0.0 - 1.0
      i++;
    }
  }
}


void keyPressed() {
  if (key=='r' || key=='R') {
    initGrid();
  }

  if (key=='s' || key=='S') {
    saveOneFrame = true;
  }
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}