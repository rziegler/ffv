pdf(file="ffv-reports-01.pdf", onefile = TRUE)
for(i in 1:length(viz.flightNumber)) {
  # print(viz.flightNumber[i])
  viz.data.flightNumber <- viz.data %>%
    filter(flightNumber==viz.flightNumber[i])
  viz.data.flightNumber$requestDay <- as.Date(strptime(viz.data.flightNumber$requestDay, "%d.%m.%Y"))  # transform to date object for plotting on x-axis
  
  viz.plots <- list()
  for(j in 1:length(viz.departureDay)) {
    #print(viz.departureDay[j])
    # A <- print(ggplot(test, aes(x=test.x, y=test.y)) + geom_line() + ggtitle("Grafik 1"))
    # B <- print(ggplot(test, aes(x=test.x, y=test.y)) + geom_line() + ggtitle("Grafik 2"))
    viz.data.flightNumber.byDepartureDay <- viz.data.flightNumber %>%
      filter(departureDay==viz.departureDay[j])
    
    #print(  # use print inside for-loops to ggplot object
    plot <- ggplot(viz.data.flightNumber.byDepartureDay, aes(x=requestDay, y=pmedian)) +
      geom_line() +
      ggtitle(sprintf(
        "Preisentwicklung eines Fluges nach Anfragedatum\n(%s am %s, %s um %s)",
        viz.data.flightNumber.byDepartureDay$flightNumber, viz.data.flightNumber.byDepartureDay$departureWeekday,
        viz.data.flightNumber.byDepartureDay$departureDay, viz.data.flightNumber.byDepartureDay$departureTime
      ))
    # append new plot t
    
    A <- ggplot(df[df$site == levels(df$site)[i],], aes(x=df$x, y=df$y1)) + geom_point() + ggtitle("A")
    viz.plots <- list(A)
    viz.plots[1] <- A
    #)
  }
  # arrange all plots of a flight on same page
  #grid.arrange(viz.plots, nrow=3, ncol=2, top="Main Title")
  do.call(grid.arrange, c(viz.plots, list(ncol=2, top="Main Title")))
  rm(viz.plots)
}
dev.off()