import java.util.List; //<>//
import java.util.ArrayList;
import java.util.*;
import java.lang.StringBuffer;
import java.lang.Math;
import java.text.SimpleDateFormat;

static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

// for moving the canvas around
int centerX = 0, centerY = 0, offsetX = 0, offsetY = 0;
float zoom = 1.5;

boolean enableMoving = false;

List<Price> prices;

int rowWidth = 10;
int rowHeight = 20;

int paddingX = 5;
int paddingY = 5;
int marginRightY = 150;

int seriesLength;

void setup() {
  //size(1420, 900);
  colorMode(RGB, 255);
  background(255);

  // moving canvas
  centerX = 0;
  centerY = 0;  
  cursor(HAND);
  smooth();

  smooth();

  prices = loadData();

  int myHeight = prices.size() * rowHeight + 2*paddingX;
  println(prices.size() + "::" + myHeight);

  int myWidth = prices.get(0).prices.size() * rowWidth + 2*paddingY + marginRightY;
  println(prices.get(0).prices.size() + "::" + myWidth);

  size(650, 32690); //23200 is the value of myHeight

  if (myHeight != height) { 
    throw new RuntimeException(String.format("Adjust the size of the canvas (height)! Actual %d, Expected %d.", height, myHeight));
  }
  if (myWidth != width) { 
    throw new RuntimeException(String.format("Adjust the size of the canvas (width)! Actual %d, Expected %d.", width, myWidth));
  }

  seriesLength = prices.get(0).prices.size();

  drawViz();
}

void draw() {
  if (enableMoving) {
    background(255);

    if (mousePressed == true) {
      centerX = mouseX-offsetX;
      centerY = mouseY-offsetY;
    } 

    translate(centerX, centerY);
    scale(zoom);

    drawViz();
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    save(String.format("p04-series%d.tif", seriesLength));
  }

  // zoom
  if (keyCode == UP) zoom += 0.05;
  if (keyCode == DOWN) zoom -= 0.05;
}

void mousePressed() {
  offsetX = mouseX-centerX;
  offsetY = mouseY-centerY;
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

  //int destinationCount = 0;
  for (TableRow row : data.rows()) {

    String fn = row.getString("flightNumber");
    String dd = row.getString("departureDate");
    String de = row.getString("destination");
    String rd = row.getString("requestDate");
    int dt = row.getInt("deltaTime");
    //float pmin = row.getFloat("pmin");
    int br = row.getInt("binRanked");

    //if (!de.equals(currentPrice.destination)) {
    //  destinationCount++;
    //  println("cnt " + destinationCount + "::" + de);
    //}

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