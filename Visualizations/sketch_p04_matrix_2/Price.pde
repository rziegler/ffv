
class Price {
  String flightNumber;
  String departureDate;
  String destination;

  List<PriceDay> prices;
  
  color priceColor;

  Price(String flightNumber, String departureDate) {
    this.flightNumber = flightNumber;
    this.departureDate = departureDate;

    this.prices = new ArrayList<PriceDay>();
  }

  public void addPrice(int bin, String date, int deltaDays) {
    PriceDay value = new PriceDay(bin, date, deltaDays);
    prices.add(value);
  }

  public String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append(destination +": "+ flightNumber +" on " + departureDate + " > ");
    for (PriceDay v : prices) {
      sb.append(v.bin +":");
    }
    return sb.toString();
  }
}