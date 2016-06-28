
/**
 * Controller for the destination circle.
 */
class DestinationCircle {

  int numOfDestinations;
  List<DestinationSlice> slices;

  DestinationSlice selectedSlice;

  public DestinationCircle(Table data) {
    slices = new ArrayList<DestinationSlice>();

    List<Destination> destinations = readDestinations(data);
    numOfDestinations = destinations.size();

    float arcPoint = PI+HALF_PI;
    float arcStep = 2*PI/numOfDestinations;

    colorMode(HSB, 360, 100, 100);
    for (Destination d : destinations) {
      DestinationSlice slice = new DestinationSlice(d);

      int i = slices.size();
      slice.centerX = centerX;
      slice.centerY = centerY;
      slice.fillColor = color(16, i*100/numOfDestinations, 95);

      slice.arcStart = arcPoint;
      slice.arcEnd = arcPoint + arcStep;
      arcPoint += arcStep;

      slices.add(slice);
    }
    colorMode(RGB, 255, 255, 255);
  }

  private List<Destination> readDestinations(Table data) {
    List<Destination> result = new ArrayList<Destination>();
    for (TableRow row : data.rows()) {
      Destination dest = new Destination(row.getString("destinationName"), row.getString("destination"), row.getFloat("avgFlightsPerDay"), row.getInt("durationMin"), row.getInt("durationMax"));
      result.add(dest);
    }
    return result;
  }

  public DestinationSlice getSlice(int index) {
    return slices.get(index);
  }

  public void selectSliceAt(int x, int y) {
    DestinationSlice oldSlice = destinationCircle.selectedSlice;
    destinationCircle.calculateSelectedSlice(x, y);
    DestinationSlice slice = destinationCircle.selectedSlice;
    println(slice.destination.name);

    destinationCircle.highlightSelectedSlice(oldSlice, slice, outerCircleRadius);
  }

  private void calculateSelectedSlice(int x, int y) {
    for (DestinationSlice s : slices) {
      if (s.isSelected(x, y)) {
        selectedSlice = s;
        break;
      }
      selectedSlice = null;
    }
  }

  public void drawInnerCircle() {
    noStroke();
    fill(60);
    ellipse(centerX, centerY, innerCircleRadius, innerCircleRadius);
  }

  public void drawOuterCircle() {
    for (DestinationSlice ds : destinationCircle.slices) {
      ds.draw(outerCircleRadius);
    }
    drawDoughnutCircle();
  }

  private void drawDoughnutCircle() {
    // draw on top to make a doughnut
    fill(255);
    ellipse(centerX, centerY, outerCircleRadius-100, outerCircleRadius-100);
  }

  public void highlightSelectedSlice(DestinationSlice oldSlice, DestinationSlice newSlice, int radius) {
    if (oldSlice != null) oldSlice.draw(radius);
    drawDoughnutCircle();
    if (newSlice != null) {
      newSlice.draw(radius);
      newSlice.drawDetail();
    }
    drawInnerCircle();
    
  }
}