import java.util.List; //<>//
import java.util.ArrayList;
import java.util.*;
import java.lang.StringBuffer;
import java.lang.Math;

public enum Destination {
  AMS, 
    BEG, 
    BKK, 
    BOM, 
    DXB, 
    GRU, 
    ICN, 
    IST, 
    JFK, 
    KEF, 
    LHR, 
    MAD, 
    MLA, 
    NRT, 
    PEK, 
    RHO, 
    RIX, 
    SIN, 
    SVO, 
    YYZ
}

List<Price> prices;
Map<Destination, List<Price>> pricesPerDestination;

int rowWidth = 10;
int rowHeight = 20;

int numberOfRows;
int maxNumOfFlights; // max number of flights

int paddingX = 5;
int paddingY = 5;
int marginRightY = 150;

int seriesLength;

void setup() {
  //size(1420, 900);
  colorMode(RGB, 255);
  background(255);

  prices = loadData();
  maxNumOfFlights = prices.size(); // if all destinations in one row
  numberOfRows = 1;

  pricesPerDestination = segmentData(prices);
  numberOfRows = 1;// Destination.values().length;

  int myHeight = maxNumOfFlights * rowHeight + 2*paddingX;
  println(prices.size() + "::" + myHeight);

  int myWidth = numberOfRows * (prices.get(0).prices.size() * rowWidth + paddingY + marginRightY) + paddingY + marginRightY;
  println(prices.get(0).prices.size() + "::" + myWidth);

  size(800, 7930); //23200 is the value of myHeight

  if (myHeight != height) { 
    throw new RuntimeException(String.format("Adjust the size of the canvas (height)! Actual %d, Expected %d.", height, myHeight));
  }
  if (myWidth != width) { 
    throw new RuntimeException(String.format("Adjust the size of the canvas (width)! Actual %d, Expected %d.", width, myWidth));
  }

  seriesLength = prices.get(0).prices.size();

  //drawViz();
  //drawVizForAllDestinations();
  drawAndSaveVizForAllDestinations();
}

void draw() {
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    save(String.format("p04-series%d.tif", seriesLength));
  }
}

private void drawViz() {
  println(String.format("Creating viz for %s prices.", prices.size()));
  for (int i=0; i<prices.size(); i++) {
    int tX = paddingX;
    int tY = paddingY + i*rowHeight;

    Price p = prices.get(i);
    drawPrices(tX, tY, p);
    drawLegend(tX+seriesLength*rowWidth+paddingX, tY, p);
  }
}

private void drawAndSaveVizForAllDestinations() {
  println("Creating viz for all destinations.");

  int i=0;
  for (Destination d : Destination.values()) {
    background(255); // clear the previous
    int offsetX = paddingX;
    drawViz(d, offsetX);
    save(String.format("p04-series%d-%s.tif", seriesLength, d).toLowerCase());
    i++;
  }
}

private void drawVizForAllDestinations() {
  println("Creating viz for all destinations.");

  int i=0;
  for (Destination d : Destination.values()) {
    if (i<numberOfRows) {
      int offsetX = paddingX + i*(seriesLength*rowWidth + paddingX + marginRightY);
      drawViz(d, offsetX);
      i++;
    }
  }

  //int offsetX = paddingX + i*(seriesLength*rowWidth + paddingX + marginRightY);
  //drawViz(Destination.AMS, offsetX);
  //i++;

  //offsetX = paddingX + i*(seriesLength*rowWidth + paddingX + marginRightY);
  //drawViz(Destination.BEG, offsetX);
  //i++;

  //offsetX = paddingX + i*(seriesLength*rowWidth + paddingX + marginRightY);
  //drawViz(Destination.LHR, offsetX);
  //i++;
}

private void drawViz(Destination destination, int offsetX) {
  List<Price> ppd = pricesPerDestination.get(destination);
  println(String.format("Creating viz for %s with %d prices.", destination, ppd.size()));
  for (int i=0; i<ppd.size(); i++) {
    int tX = paddingX+ offsetX;
    int tY = paddingY + i*rowHeight;

    Price p = ppd.get(i);
    drawPrices(tX, tY, p);
    drawLegend(tX+seriesLength*rowWidth+paddingX, tY, p);
  }
}

private void drawLegend(int translateX, int translateY, Price p) {
  translate(translateX, translateY);
  pushStyle();
  fill(0);
  int textHeight = 10;
  textSize(textHeight);
  rectMode(CORNER);
  text(String.format("%s: %s %s", p.destination, p.flightNumber, p.departureDate), 0, textHeight + (rowHeight-textHeight)/2);
  popStyle();
  translate(-translateX, -translateY);
}

private void drawPrices(int translateX, int translateY, Price p) {
  translate(translateX, translateY);
  for (int i=0; i<p.prices.size(); i++) {
    drawPrice(p.prices.get(i), i);
  }
  translate(-translateX, -translateY);
}

private void drawPrice(PriceDay price, int index) {
  pushStyle();
  stroke(#ffffff);
  strokeWeight(0.1);
  fill(getColor(price.bin));
  rect(index*rowWidth, 0, rowWidth, rowHeight);
  popStyle();
}

private color getColor(int bin) {
  color result = #FFFFFF;
  switch(bin) {
  case 1:
    result = #2166ac;
    break;
  case 2:
    result = #67a9cf;
    break;
  case 3:
    result = #d1e5f0;
    break;
  case 4:
  default:
    result = #f7f7f7;
    break;
  case 5:
    result = #fddbc7;
    break;
  case 6:
    result = #ef8a62;
    break;
  case 7:
    result = #b2182b;
    break;
  }
  return result;
}

private List<Price> loadData() {
  Table data = loadTable("data-all.csv", "header");

  List<Price> result = new ArrayList<Price>();
  Price currentPrice = new Price("xx", "xx"); // initialize with a dummy price

  for (TableRow row : data.rows()) {

    String fn = row.getString("flightNumber");
    String dd = row.getString("departureDate");
    String de = row.getString("destination");
    String rd = row.getString("requestDate");
    int dt = row.getInt("deltaTime");
    //float pmin = row.getFloat("pmin");
    int br = row.getInt("binRanked");

    if (fn.equals(currentPrice.flightNumber) && dd.equals(currentPrice.departureDate)) {
      currentPrice.addPrice(br, rd, dt);
    } else {
      currentPrice = new Price(fn, dd);
      currentPrice.destination = de;
      currentPrice.addPrice(br, rd, dt);
      result.add(currentPrice);
    }
  }
  return result;
}

private Map<Destination, List<Price>> segmentData(List<Price> prices) {
  maxNumOfFlights = 0;
  Map<Destination, List<Price>> result = new HashMap<Destination, List<Price>>();

  for (Destination d : Destination.values()) {
    result.put(d, new ArrayList<Price>());
  }

  for (Price p : prices) {
    Destination d = Destination.valueOf(p.destination);
    List<Price> list = result.get(d);
    list.add(p);
  }

  int total = 0;
  for (Destination d : Destination.values()) {
    int numOfFlights = result.get(d).size();
    maxNumOfFlights = Math.max(maxNumOfFlights, numOfFlights);

    println(String.format("%s has %d flights", d, numOfFlights));
    total += numOfFlights;
  }
  println(String.format("Total flights is %d. maxNumOfFlights is %d", total, maxNumOfFlights));
  return result;
}