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
  
  centerX = width/2-150;
  centerY = height/2;
  
  initCircleFromData();
  
  destinationCircle.drawOuterCircle();
  destinationCircle.drawInnerCircle();
}

void draw() {
  
}

void mouseClicked() {
  destinationCircle.selectSliceAt(mouseX, mouseY);
}

void initCircleFromData() {
  Table table = loadTable("data-destinations-condensed.csv","header");
  destinationCircle = new DestinationCircle(table);
}

boolean isMouseInsideSlice(int x, int y) {
  return true;
}