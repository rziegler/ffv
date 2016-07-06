import java.util.Map;

class PriceDevelopment {

  String departureDate;
  Map<String, Float> prices;
  
  public PriceDevelopment(String dd) {
    this.departureDate = dd;
    this.prices = new HashMap<String, Float>();
  }
  
  public void addPrice(float price, String date) {
    prices.put(date, new Float(price));
  }
}