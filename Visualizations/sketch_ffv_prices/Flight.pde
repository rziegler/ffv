import java.util.List;

class Flight {
  
  List<PriceDevelopment> priceDevelopments;
  
  public Flight() {
    
  }
  
  public void init() {
    Table table = loadTable("data-lx316.csv","header");
    priceDevelopments = readData(table);
    println(priceDevelopments.size() + " " + priceDevelopments.get(0).prices.size());
  }
  
  private List<PriceDevelopment> readData(Table data) {
    List<PriceDevelopment> result = new ArrayList<PriceDevelopment>();
    
    PriceDevelopment currentPd = null;
    
    for (TableRow row : data.rows()) {
      
      String dd = row.getString("departureDate");
      String rd = row.getString("requestDate");
      float p = row.getFloat("pmin");
      
      if(currentPd == null || !dd.equals(currentPd.departureDate)) {
        // new price dev
        currentPd = new PriceDevelopment(dd);
        result.add(currentPd);     
      } 
      
      // add price to current pd
      currentPd.addPrice(p, rd);
    }
    return result;
  }
}