
class Price {
  String flightNumber;
  String departureDate;
  String destination;

  List<PriceDay> prices;
  List<PriceDay> mins;
  List<PriceDay> maxs;
  
  color priceColor;

  Price(String flightNumber, String departureDate) {
    this.flightNumber = flightNumber;
    this.departureDate = departureDate;

    this.prices = new ArrayList<PriceDay>();
    
    mins = new ArrayList<PriceDay>();
    mins.add(new PriceDay(Float.MAX_VALUE, "xx-xx-xxxx", Integer.MAX_VALUE));
    maxs = new ArrayList<PriceDay>();
    maxs.add(new PriceDay(Float.MIN_VALUE, "xx-xx-xxxx", Integer.MIN_VALUE));
  }

  public void addPrice(float price, String date, int deltaDays) {
    PriceDay value = new PriceDay(price, date, deltaDays);
    prices.add(value);
    if (value.price < mins.get(0).price) {
      mins.clear();
      mins.add(value);
    } else if(value.price == mins.get(0).price) {
      mins.add(value);
    }

    if (value.price > maxs.get(0).price) {
      maxs.clear();
      maxs.add(value);
    } else if(value.price == maxs.get(0).price) {
      maxs.add(value);
    }
  }

  public List<PriceDay> getMin() {
    return mins;
  }

  public List<PriceDay> getMax() {
    return maxs;
  }

  public String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append(destination +": "+ flightNumber +" on " + departureDate + " > ");
    for (PriceDay v : prices) {
      sb.append(v.price +":");
    }
    return sb.toString();
  }
}