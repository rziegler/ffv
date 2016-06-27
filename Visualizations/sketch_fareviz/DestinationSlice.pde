
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
}