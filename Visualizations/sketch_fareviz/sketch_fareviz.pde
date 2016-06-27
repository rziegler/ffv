import java.util.List;
import java.util.ArrayList;

//List<DestinationSlice> destinationSlices;
DestinationCircle destinationCircle;

int innerCircleRadius = 50;
int outerCircleRadius = 800;

int centerX;
int centerY;

void setup() {
  size(1200,900);
  background(255);
  noLoop();
  
  centerX = width/2-150;
  centerY = height/2;
  
  initCircleFromData();
  
  drawOuterCircle();
  drawInnerCircle();
}

void draw() {
  
  
}

void mouseClicked() {
  destinationCircle.calculateSelectedSlice(mouseX, mouseY);
  println(destinationCircle.selectedSlice.destination.name);
}

void initCircleFromData() {
  Table table = loadTable("data-destinations-condensed.csv","header");
  destinationCircle = new DestinationCircle(table);
}

boolean isMouseInsideSlice(int x, int y) {
  return true;
}

void drawInnerCircle() {
  noStroke();
  fill(60);
  ellipse(centerX, centerY, innerCircleRadius, innerCircleRadius);
}

void drawOuterCircle() {
  
  for(DestinationSlice ds : destinationCircle.slices) {
    ds.draw(outerCircleRadius);
  }
  
  // draw on top to make a doughnut
  fill(255);
  ellipse(centerX, centerY, outerCircleRadius-100, outerCircleRadius-100);
}