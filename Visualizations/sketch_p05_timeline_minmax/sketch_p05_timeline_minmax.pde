import java.util.List;
import java.util.ArrayList;
import java.util.*;
import java.lang.StringBuffer;
import java.lang.Math;
import java.text.SimpleDateFormat;

static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

List<Price> prices;

int width = 200;
int height = 100;

int paddingX = 5;
int paddingY = 5;
int tickLength = 2;
int vizCols = 5;

int startX = 0+paddingX;
int endX = width-paddingX;

int seriesLength;

void setup() {
  //size(1420, 900);
  colorMode(RGB, 255);
  background(255);
  smooth();

  prices = loadData();
  
  int myHeight = prices.size()/vizCols * height;
  println(prices.size()/vizCols + "::" + myHeight);
  int myWidth = vizCols * width + 2*10;
  println(vizCols + "::" + myWidth);
  
  size(1020, 23200); //23200 is the value of myHeight
  
  //if (myHeight != height) { 
  //  throw new RuntimeException(String.format("Adjust the size of the canvas (height)! Actual %d, Expected %d.", height, myHeight));
  //}
  //if (myWidth != width) { 
  //  throw new RuntimeException(String.format("Adjust the size of the canvas (width)! Actual %d, Expected %d.", width, myWidth));
  //}
  
  seriesLength = prices.get(0).prices.size();
  int timelineTicks = seriesLength + 1; // + 1 because departure date is also on the timeline
  //int timelineTicks = 6;

  println(String.format("Creating viz for %s prices.", prices.size()));
  for (int i=0; i<prices.size(); i++) {
    int tX = 10+(i%vizCols)*width;
    int tY = 10+(i/vizCols)*height;
    
    Price p = prices.get(i);
    drawBox(tX, tY);
    
    drawArcs(tX, tY, seriesLength, p.getMin(), #00FF00);
    drawArcs(tX, tY, seriesLength, p.getMax(), #FF0000);
    drawLegend(tX, tY, p);
    drawTimeline(tX, tY, timelineTicks);
  }
}

void draw() {
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    save("p05.tif");
  }
}

private void drawBox(int translateX, int translateY) {
  translate(translateX, translateY);
  rect(0, 0, width, height);
  translate(-translateX, -translateY);
}

private void drawTimeline(int translateX, int translateY, int ticks) {
  translate(translateX, translateY);
  line(startX, height/2, endX, height/2);

  for (int i=0; i<ticks; i++) {
    float t = map(i, 0, ticks-1, 0, endX - startX);
    line(t+paddingX, height/2-tickLength, t+paddingX, height/2+tickLength);
  }
  translate(-translateX, -translateY);
}

private void drawArcs(int translateX, int translateY, int seriesLength, List<PriceDay> pds, color arcColor) {
  for (PriceDay pd : pds) {
    int from = seriesLength - pd.deltaDays;
    drawArc(translateX, translateY, seriesLength, pd.price, from, seriesLength, arcColor);
  }
}

private void drawArc(int translateX, int translateY, int seriesLength, float price, int from, int to, color arcColor) {
  translate(translateX, translateY);
  pushStyle();
  ellipseMode(CENTER);
  noFill();
  stroke(arcColor);

  float start = map(from, 0, seriesLength, 0, endX - startX);
  float end = map(to, 0, seriesLength, 0, endX - startX);
  float arcWidth = end-start;
  float arcHeight = map(end-start, 0, end, 10, height-10*paddingY);

  strokeWeight(price/100);
  arc(paddingX + start + (end-start)/2, height/2, arcWidth, arcHeight, PI, 2*PI);
  popStyle();
  translate(-translateX, -translateY);
}

private void drawLegend(int translateX, int translateY, Price current) {
  translate(translateX, translateY);
  pushStyle();
  fill(0);
  text(current.destination, 10, 10);
  text(current.flightNumber, 10, 20);
  text(current.departureDate, 10, 30);
  
  popStyle();
  translate(-translateX, -translateY);
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
    float pmin = row.getFloat("pmin");

    //if (!de.equals(currentPrice.destination)) {
    //  destinationCount++;
    //  println("cnt " + destinationCount + "::" + de);
    //}

    if (fn.equals(currentPrice.flightNumber) && dd.equals(currentPrice.departureDate)) {
      currentPrice.addPrice(pmin, rd, dt);
    } else {
      currentPrice = new Price(fn, dd);
      currentPrice.destination = de;
      currentPrice.addPrice(pmin, rd, dt);

      //println("cnt " + destinationCount + "::" + de);
      colorMode(HSB, 45);
      //currentPrice.priceColor = color(destinationCount, 45, 45);
      currentPrice.priceColor = color(45, 45, 45);

      result.add(currentPrice);
    }
  }
  return result;
}