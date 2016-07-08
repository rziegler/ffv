function savingsFfv(csvFileName) {

    var width = 300,
        height = 300;

    var svg = d3.select("#chartSavings").append("div")
        .classed("svg-container", true) //container class to make it responsive
        .classed("twelve columns", true)
        .append("svg")
        //responsive SVG needs these 2 attributes and no width and height attr
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 0 " + width + " " + height)
        //class to make it responsive
        .classed("svg-content-responsive", true);

    d3.csv(csvFileName, function (d) {
        return {
            flightNumber: d.flightNumber,
            departureDate: d.departureDate,
            requestDate: d.requestDate,
            origin: d.origin,
            destination: d.destination,
            pmin: +d.pmin
        };
    }, function (error, data) {
        if (error) throw error;

        // calculate min and max price and savings in percent for each departure day
        data = d3.nest()
            .key(function (d) {
                return d.departureDate;
            })
            .rollup(function (v) {
                return {
                    flightNumber: v.flightNumber,
                    min: d3.min(v, function (d) {
                        return d.pmin;
                    }),
                    max: d3.max(v, function (d) {
                        return d.pmin;
                    }),
                    savingsPercent: ((d3.max(v, function (d) {
                        return d.pmin;
                    })) - (d3.min(v, function (d) {
                        return d.pmin;
                    }))) / (d3.max(v, function (d) {
                        return d.pmin;
                    }))
                };
            })
            .entries(data);

        // calculate mean of savings for all flights
        var meanPercent = d3.mean(data, function (d) {
            return d.values.savingsPercent;
        });

        var meanPercentRounded = Math.round(meanPercent * 100)
        console.log(meanPercentRounded);

        var step = (width - 40) / 10;
        var g = svg
            .append("g")
            .attr("transform", "translate(" + 10 + "," + 10 + ")");
        for (i = 0; i < 100; i++) {
            console.log("!" + ((i % 10)) + ".." + (Math.round(i / 10)));
            g.append("circle").attr("cx", function (d) {
                    return (i % 10) * step;
                })
                .attr("cy", function (d) {
                    return Math.floor(i / 10) * step;
                })
                .attr("r", function (d) {
                    return 5;
                })
                .style("fill", function (d) {
                    if (i <= meanPercentRounded) {
                        return "#454545";
                    } else {
                        return "#17960E";
                    }
                });
        }

        console.log(meanPercent);


    });

}