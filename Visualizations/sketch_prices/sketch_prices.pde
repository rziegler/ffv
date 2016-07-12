import java.util.List;
import java.util.ArrayList;
import java.util.*;

List<Price> prices;

int offsetY = 100;
int spaceBetweenLines = 5;
int lineHeight = 10;

int lineWithSpace = lineHeight + spaceBetweenLines;

PriceMode currentPriceMode = PriceMode.ABSOLUTE;

Price unselectedPrice;
int unselectedPriceIndex;

Price selectedPrice;
int selectedPriceIndex;

boolean selectedPriceDrawn = false;

public enum Mode {
  VERTEX_LINE, VERTEX_POINTS;
}

void setup() {
  //size(1200, 900);

  prices = loadData();
  int myHeight = prices.size()* lineWithSpace + offsetY;
  println(prices.size() + "::" + myHeight);
  size(1200, 34750); //23200 is the value of myHeight
  if (myHeight != height) { 
    throw new RuntimeException("Adjust the size of the canvas!");
  }
  background(255);
  smooth();

  //noLoop();
  drawAllPrices();
}

void draw() {
  if (selectedPrice != null && !selectedPriceDrawn) {
    if (unselectedPrice != null && !selectedPriceDrawn) {
      // redraw adjacent prices of unselected prices as well -> otherwise it looks not nice if spaceBetweenLines is 0
      pushStyle();
      noStroke();
      fill(255);
      // draw a white rect to cover the unselected price and its neighbours...
      int y1 = lineWithSpace * (unselectedPriceIndex-1) + offsetY - lineWithSpace/2;
      rect(0, y1, width, 3*lineWithSpace);
      popStyle();
      // ... then redraw them
      Price prevPrice = prices.get(unselectedPriceIndex-1);
      Price nextPrice = prices.get(unselectedPriceIndex+1);
      drawPrice(prevPrice.prices.get(currentPriceMode), Mode.VERTEX_LINE, 1.0, prevPrice.priceColor, unselectedPriceIndex-1);
      drawPrice(unselectedPrice.prices.get(currentPriceMode), Mode.VERTEX_LINE, 1.0, unselectedPrice.priceColor, unselectedPriceIndex);
      drawPrice(nextPrice.prices.get(currentPriceMode), Mode.VERTEX_LINE, 1.0, nextPrice.priceColor, unselectedPriceIndex+1);
    }

    drawPrice(selectedPrice.prices.get(currentPriceMode), Mode.VERTEX_LINE, 3.0, selectedPrice.priceColor, selectedPriceIndex);
    selectedPriceDrawn = true;
  }
}

void mouseClicked() {
  selectedPriceDrawn = false;

  unselectedPriceIndex = selectedPriceIndex;
  unselectedPrice = selectedPrice;

  selectedPriceIndex = (mouseY - offsetY)/lineWithSpace;
  selectedPrice = prices.get(selectedPriceIndex);
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    save(String.format("prices-%s.tif", currentPriceMode));
  }

  if (key == 'a' || key == 'A') {
    currentPriceMode = PriceMode.ABSOLUTE;
    clearCanvas();
    drawAllPrices();
  }
  if (key == 'r' || key == 'R') {
    currentPriceMode = PriceMode.RELATIVE;
    clearCanvas();
    drawAllPrices();
  }
}

private void clearCanvas() {
  pushStyle();
  noStroke();
  fill(255);
  rect(0, 0+offsetY- lineWithSpace/2, width, height-offsetY+ lineWithSpace/2);
  popStyle();
}

private void drawAllPrices() {
  int i=0;
  for (Price p : prices) {
    //drawPrice(p.prices, Mode.VERTEX_LINE, 1.0, width/(p.prices.size()-1), lineWithSpace * i + offsetY, lineHeight);
    drawPrice(p.prices.get(currentPriceMode), Mode.VERTEX_LINE, 1.0, p.priceColor, i);
    i++;
  }
}

private void drawPrice(List<Integer> prices, Mode mode, float strokeWeight, color col, int i) {
  drawPrice(prices, mode, strokeWeight, col, width/(prices.size()-1), lineWithSpace * i + offsetY, lineHeight);
}

private void drawPrice(List<Integer> prices, Mode mode, float strokeWeight, color col, int xStepSize, int yBase, int yBandWidth) {
  colorMode(HSB);
  noFill();
  stroke(col);
  strokeWeight(strokeWeight);
  switch(mode) {
  case VERTEX_POINTS: 
    beginShape(POINTS); 
    break;
  case VERTEX_LINE: 
  default: 
    beginShape(); 
    break;
  }
  drawVertexes(prices, xStepSize, yBase, yBandWidth);
  endShape();
  colorMode(RGB);
}

private void drawVertexes(List<Integer> prices, int xStepSize, int yBase, int yBandWidth) {
  int idx = 0;
  for (Integer p : prices) {
    vertex(idx * xStepSize, yBase + yBandWidth/2*(-1*p));
    idx++;
  }
}

private List<Price> loadData() {
  Table data = loadTable("data-all.csv", "header");

  List<Price> result = new ArrayList<Price>();
  Price currentPrice = new Price("xx", "xx"); // initialize with a dummy price

  int destinationCount = 0;
  for (TableRow row : data.rows()) {

    String fn = row.getString("flightNumber");
    String dd = row.getString("departureDate");
    String de = row.getString("destination");
    int prel = row.getInt("priceChangeRelBoolean");
    int pabs = row.getInt("priceChangeAbsBoolean");



    if (!de.equals(currentPrice.destination)) {
      destinationCount++;
      println("cnt " + destinationCount + "::" + de);
    }

    if (fn.equals(currentPrice.flightNumber) && dd.equals(currentPrice.departureDate)) {
      currentPrice.addPrice(pabs, PriceMode.ABSOLUTE);
      currentPrice.addPrice(prel, PriceMode.RELATIVE);
    } else {
      currentPrice = new Price(fn, dd);
      currentPrice.destination = de;

      //println("cnt " + destinationCount + "::" + de);
      colorMode(HSB, 45);
      currentPrice.priceColor = color(destinationCount, 45, 45);
      currentPrice.addPrice(pabs, PriceMode.ABSOLUTE);
      currentPrice.addPrice(prel, PriceMode.RELATIVE);
      result.add(currentPrice);
    }
  }
  return result;
}