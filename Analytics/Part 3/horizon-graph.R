#
# Arguments: Data, number of bands, positive color, and negative color
#

horizonGraph <- function(values, num_bands=3, max_value=max(abs(values)), base_col_pos="blue", base_col_neg="red", main="") {
    
    #
    # Color ramp functions
    #
    colPosFn <- colorRampPalette(c("white", base_col_pos))
    colNegFn <- colorRampPalette(c("white", base_col_neg))
	col_pos <- colPosFn(num_bands+1)
    col_neg <- colNegFn(num_bands+1)


    #
    # Find band breaks
    #
	band_interval <- max_value / num_bands
	band_breaks <- seq(0, max_value, by=band_interval)
	
	#
	# Start graph with final limits (height of band_interval)
	#
	par(cex.main=0.8)
	plot(values, xlim=c(1, length(values)), ylim=c(0, band_interval), type="n", axes=FALSE, main=main, xlab="", ylab="")
	
	#
	# Draw positive bands
	#
	
	for (i in 2:length(band_breaks)) {
		b <- band_breaks[i]
		bprev <- band_breaks[i-1]
		x <- 1:length(values)
		y <- values
		
		# Intersections with bottom band break
        above_bottom <- values > bprev
        intersect_bottom <- which(diff(above_bottom) != 0)
        slopes_bottom <- values[intersect_bottom+1] - values[intersect_bottom]
        newx_bottom <- (bprev - values[intersect_bottom]) / slopes_bottom + intersect_bottom
        x <- c( x, newx_bottom )
        y <- c( y, rep(bprev, length(newx_bottom)) )
        
        # Intersections with top band break
        above_top <- values > b
        intersect_top <- which(diff(above_top) != 0)
        slopes_top <- values[intersect_top+1] - values[intersect_top]
        newx_top <- (b - values[intersect_top]) / slopes_top + intersect_top
        x <- c(x, newx_top)
        y <- c( y, rep(b, length(newx_top)) )
        
        # Cut out the band
        band_df <- data.frame(x,y)
        band_df <- band_df[order(band_df$x),]
        band_df$y <- sapply(band_df$y, FUN=function(val) {
        	if (val < bprev) {
        		return(bprev)
        	} else if (val > b) {
        		return(b)
        	} else {
        		return(val)
        	}
        })
        
        # Vertical offset
        yoffset <- (i-2) * band_interval
        
        # Color
    	col <- col_pos[i]
    	
    	# Draw band with polygon
    	xpoly <- c(band_df$x, max(band_df$x), band_df$x[1], band_df$x[1])
        ypoly <- c(band_df$y, bprev, bprev, band_df$y[1]) - yoffset
        
        if (sum(ypoly) > 0) {
        	polygon(xpoly, ypoly, col=col, border=NA)
        }
        	
	}
	
	
	
	#
	# Draw negative bands
	#
	values_mirr <- -values
	
	for (i in 2:length(band_breaks)) {
		b <- band_breaks[i]
		bprev <- band_breaks[i-1]
		x <- 1:length(values)
		y <- values_mirr
		
		# Intersections with bottom band break
        above_bottom <- values_mirr > bprev
        intersect_bottom <- which(diff(above_bottom) != 0)
        slopes_bottom <- values_mirr[intersect_bottom+1] - values_mirr[intersect_bottom]
        newx_bottom <- (bprev - values_mirr[intersect_bottom]) / slopes_bottom + intersect_bottom
        x <- c( x, newx_bottom )
        y <- c( y, rep(bprev, length(newx_bottom)) )
        
        # Intersections with top band break
        above_top <- values_mirr > b
        intersect_top <- which(diff(above_top) != 0)
        slopes_top <- values_mirr[intersect_top+1] - values_mirr[intersect_top]
        newx_top <- (b - values_mirr[intersect_top]) / slopes_top + intersect_top
        x <- c(x, newx_top)
        y <- c( y, rep(b, length(newx_top)) )
        
        # Cut out the band
        band_df <- data.frame(x,y)
        band_df <- band_df[order(band_df$x),]
        band_df$y <- sapply(band_df$y, FUN=function(val) {
        	if (val < bprev) {
        		return(bprev)
        	} else if (val > b) {
        		return(b)
        	} else {
        		return(val)
        	}
        })
        
        # Vertical offset
        yoffset <- (i-2) * band_interval
        
        # Color
    	col <- col_neg[i]
    	
    	# Draw band with polygon
    	xpoly <- c(band_df$x, max(band_df$x), band_df$x[1], band_df$x[1])
        ypoly <- c(band_df$y, bprev, bprev, band_df$y[1]) - yoffset
        
        if (sum(ypoly) > 0) {
        	polygon(xpoly, ypoly, col=col, border=NA)
        }   	
	}
	
}
