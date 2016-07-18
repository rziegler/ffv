
class Price {
  String flightNumber;
  String departureDate;
  String destination;

  List<Float> prices;
  Float min = Float.MAX_VALUE;
  Float max = Float.MIN_VALUE;

  color priceColor;

  Price(String flightNumber, String departureDate) {
    this.flightNumber = flightNumber;
    this.departureDate = departureDate;

    this.prices = new ArrayList<Float>();
  }

  public void addPrice(float price) {
    Float value = new Float(price);
    prices.add(value);
    if (value < min) {
      min = value;
    }

    if (value > max) {
      max = value;
    }
  }

  public float getMin() {
    return min;
  }

  public float getMax() {
    return max;
  }

  public String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append(destination +": "+ flightNumber +" on " + departureDate + " > ");
    for (Float v : prices) {
      sb.append(v +":");
    }
    return sb.toString();
  }
}