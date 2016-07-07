function horizonSample() {

    var width = 1360,
        height = 200;

    var chart = d3.horizon()
        .width(width)
        .height(height)
        .bands(3)
        .mode("mirror")
        .interpolate("basis");

    var svg = d3.select("body").append("svg")
        .attr("width", width)
        .attr("height", height);

    d3.json("unemployment.json", function (error, data) {
        if (error) throw error;

        // Offset so that positive is above-average and negative is below-average.
        var mean = data.rate.reduce(function (p, v) {
            return p + v;
        }, 0) / data.rate.length;

        // Transpose column values to rows.
        data = data.rate.map(function (rate, i) {
            return [Date.UTC(data.year[i], data.month[i] - 1), rate - mean];
        });

        // Render the chart.
        svg.data([data]).call(chart);

        //        // Enable mode buttons.
        //        d3.selectAll("#horizon-controls input[name=mode]").on("change", function () {
        //            svg.call(chart.duration(0).mode(this.value));
        //        });
        //
        //        // Enable bands buttons.
        //        d3.selectAll("#horizon-bands button").data([-1, 1]).on("click", function (d) {
        //            var n = Math.max(1, chart.bands() + d);
        //            d3.select("#horizon-bands-value").text(n);
        //            svg.call(chart.duration(1000).bands(n).height(height / n));
        //        });
    });
}

function horizonFfv(csvFileName, forDepartureDate) {

    var width = 1360,
        height = 200;

    var chart = d3.horizon()
        .width(width)
        .height(height)
        .bands(5)
        .mode("mirror")
        .interpolate("basis");

    var svg = d3.select("#chartPrice").append("div")
        .classed("svg-container", true) //container class to make it responsive
        .append("svg")

    //responsive SVG needs these 2 attributes and no width and height attr
    .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 0 1360 200")
        //class to make it responsive
        .classed("svg-content-responsive", true);
    //    .attr("width", width)
    //        .attr("height", height);

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

        data = data.filter(function (d) {
            return d.departureDate == forDepartureDate;
        });

        // Offset so that positive is above-average and negative is below-average.
        var mean = data.reduce(function (p, v) {
            return p + v.pmin;
        }, 0) / data.length;

        // Transpose column values to rows.
        data = data.map(function (current, i) {
            //            return [Date.UTC(current.requestDate), current.pmin - mean];
            return [Date.parse(current.requestDate), current.pmin - mean];
        });

        // Render the chart.
        svg.data([data]).call(chart);

        svg.append("text")
            .attr("transform", function (d) {
                return "translate(10, " + 18 + ")";
            })
            .attr("dy", ".35em")
            .text(function (d) {
                return dateFormat(forDepartureDate, "fullDate");
            });
    });

}