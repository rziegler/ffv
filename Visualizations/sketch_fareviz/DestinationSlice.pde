
class DestinationSlice {

  Destination destination;

  int centerX;
  int centerY;
  float arcStart;
  float arcEnd;

  PVector start;
  PVector end;
  float maxAngle;

  color fillColor;

  DestinationSlice(Destination destination) {
    this.destination = destination;
  }

  void draw(int radius) {
    noStroke();
    fill(fillColor);
    arc(centerX, centerY, radius, radius, arcStart, arcEnd, PIE);
  }

  void drawDetail() {
    noStroke();
    fill(fillColor);

    pushMatrix();
    translate(width - 280, 100);
    rect(0, 0, 220, 300);

    fill(60);
    textSize(22);
    text(destination.name.toUpperCase(), 10, 30);
    textSize(16);
    text(destination.code, 10, 50);

    text("Flüge pro Tag", 10, 80, 200, 100);
    drawPoints(destination.avgFlightsPerDay, 15, 110, 200);

    text(String.format("Dauer\nzwischen %d-%d", destination.durationMin, destination.durationMax), 10, 160);
    popMatrix();
  }

  boolean isSelected(int x, int y) {
    if (start == null) { // lazy initialize
      start = PVector.fromAngle(arcStart);
      end = PVector.fromAngle(arcEnd);
      maxAngle = PVector.angleBetween(start, end);
    }
    //println(String.format("v1 %s, v2 %s", start, end));

    PVector currentPoint = new PVector(x-centerX, y-centerY);
    //println(String.format("cp %s", currentPoint));
    float angleSCP = PVector.angleBetween(start, currentPoint);
    float angleCPE = PVector.angleBetween(currentPoint, end);

    boolean result = angleSCP < maxAngle && angleCPE < maxAngle;
    //println(String.format("b1 = %f, b2 = %f, dd %f", b1, b2, maxAngle));
    //println(result);
    return result;
  }

  private void drawPoints(float numberOfPoints, int x, int y, int maxWidth) {
    noStroke();
    fill(60);
    int step = 10;
    for (int i = 0; i < numberOfPoints; i++) {
      if(i%6 == 5) {
        ellipse(x + i*step +10, y, 8, 8);
      }else {
        ellipse(x + i*step, y, 8, 8);
      }
    }
  }
}