public enum PriceMode {
  ABSOLUTE, RELATIVE;
}

class Price {
  String flightNumber;
  String departureDate;
  String destination;
  
  Map<PriceMode, List<Integer>> prices;
  //List<Integer> prices;
  
  color priceColor;
  
  Price(String flightNumber, String departureDate) {
  this.flightNumber = flightNumber;
  this.departureDate = departureDate;
  
  this.prices = new HashMap<PriceMode, List<Integer>>();
  prices.put(PriceMode.ABSOLUTE,new ArrayList<Integer>());
  prices.put(PriceMode.RELATIVE,new ArrayList<Integer>());
  
  //this.prices = new ArrayList<Integer>();
  }
  
  public void addPrice(int price, PriceMode mode) {
    List<Integer> tmp = prices.get(mode);
    tmp.add(new Integer(price));
  }
  
  
  
}