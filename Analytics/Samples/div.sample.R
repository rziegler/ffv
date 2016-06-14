df <- data.frame(gp = factor(rep(letters[1:3], each = 10)),
                 y = rnorm(30))
# Compute sample mean and standard deviation in each group
ds <- plyr::ddply(df, "gp", plyr::summarise, mean = mean(y), sd = sd(y))

# Declare the data frame and common aesthetics.
# The summary data frame ds is used to plot
# larger red points in a second geom_point() layer.
# If the data = argument is not specified, it uses the
# declared data frame from ggplot(); ditto for the aesthetics.
ggplot(df, aes(x = gp, y = y)) +
  geom_point() +
  geom_point(data = ds, aes(y = mean),
             colour = 'red', size = 3)


times <- structure(c(1331086009.50098, 1331091427.42461, 1331252565.99979, 
                     1331252675.81601, 1331262597.72474, 1331262641.11786, 1331269557.4059, 
                     1331278779.26727, 1331448476.96126, 1331452596.13806), class = c("POSIXct", 
                                                                                      "POSIXt"))
t <- strftime(times, format="%H:%M:%S")


t1 <- as.POSIXct(strptime("2011-03-27 01:30:00", "%Y-%m-%d %H:%M:%S"))
t2 <- as.POSIXct(strptime("2011-03-29 01:30:00", "%Y-%m-%d %H:%M:%S"))
difftime(t1, t2, units = c("days"))


# Spread and gather are complements
df <- data.frame(x = c("a", "b"), y = c(3, 4), z = c(5, 6))

dd <- df %>% spread(x, y)
%>% gather(x, y, a:b, na.rm = TRUE)

svp.anteil <- c(11.1,9.9,11.6,11.1,11,11.9,14.9,22.5,26.7,28.9,26.6,29.4)
jahr <- seq(1971,2015,4)
daten <- data.frame(svp.anteil,jahr)

ggplot(daten, aes(x=jahr, y=svp.anteil)) + 
  geom_line() + 
  ggtitle("Liniendiagramm")


## read in date/time info in format 'm/d/y h:m:s'
dates <- c("02/27/92", "02/27/92", "01/14/92", "02/28/92", "02/01/92")
times <- c("23:03:20", "22:29:56", "01:03:30", "18:21:03", "16:56:26")
xx <- paste(dates, times)
yy <- strptime(xx, "%m/%d/%y")
