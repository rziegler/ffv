import java.util.List;
import java.util.ArrayList;
import java.util.*;
import java.lang.StringBuffer;
import java.lang.Math;


List<Price> prices;

int width = 400;
int height = 200;

int paddingX = 5;
int paddingY = 5;
int tickLength = 2;

int startX = 0+paddingX;
int endX = width-paddingX;

void setup() {
  size(1200, 900);
  colorMode(RGB, 255);
  background(255);
  smooth();

  prices = loadData();
  println(prices.size());
  int i = 0;
  println(prices.get(i).getMin());
  println(prices.get(i).getMax());
  println(prices.get(i).toString());
  println(prices.get(i).prices.size());

  int timelineTicks = prices.get(0).prices.size() + 1; // + 1 because departure date is also on the timeline
  //int timelineTicks = 6;

  drawBox(10, 10);
  drawArc(10, 10, timelineTicks, prices.get(0).getMin(), 0, 28);
  drawArc(10, 10, timelineTicks, prices.get(0).getMax(), 10, 28);
  drawTimeline(10, 10, timelineTicks);
}

void draw() {
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

private void drawArc(int translateX, int translateY, int ticks, float price, int from, int to) {
  translate(translateX, translateY);
  pushStyle();
  ellipseMode(CENTER);
  noFill();

  float start = map(from, 0, ticks-1, 0, endX - startX);
  float end = map(to, 0, ticks-1, 0, endX - startX);
  float arcWidth = end-start;
  float arcHeight = map(end-start, 0, end, 10, height-10*paddingY);
  
  strokeWeight(price/100);
  arc(paddingX + start + (end-start)/2, height/2, arcWidth, arcHeight, PI, 2*PI);
  popStyle();
  translate(-translateX, -translateY);
}


private List<Price> loadData() {
  Table data = loadTable("data-lx316.csv", "header");

  List<Price> result = new ArrayList<Price>();
  Price currentPrice = new Price("xx", "xx"); // initialize with a dummy price

  int destinationCount = 0;
  for (TableRow row : data.rows()) {

    String fn = row.getString("flightNumber");
    String dd = row.getString("departureDate");
    String de = row.getString("destination");
    float pmin = row.getFloat("pmin");

    //if (!de.equals(currentPrice.destination)) {
    //  destinationCount++;
    //  println("cnt " + destinationCount + "::" + de);
    //}

    if (fn.equals(currentPrice.flightNumber) && dd.equals(currentPrice.departureDate)) {
      currentPrice.addPrice(pmin);
    } else {
      currentPrice = new Price(fn, dd);
      currentPrice.destination = de;
      currentPrice.addPrice(pmin);

      //println("cnt " + destinationCount + "::" + de);
      colorMode(HSB, 45);
      //currentPrice.priceColor = color(destinationCount, 45, 45);
      currentPrice.priceColor = color(45, 45, 45);

      result.add(currentPrice);
    }
  }
  return result;
}