function createWeekdayPieChart(idTagName, csvFileName, weekdayColumnName) {

    var width = 300,
        height = 300,
        radius = Math.min(width, height) / 2;

    var weekdayOrder = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"];

    var color = d3.scale.ordinal()
        .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

    var arc = d3.svg.arc()
        .outerRadius(radius - 10)
        .innerRadius(radius - 70);

    var pie = d3.layout.pie()
        .sort(function (a, b) {
            var aIdx = weekdayOrder.indexOf(a.key);
            var bIdx = weekdayOrder.indexOf(b.key);
            return aIdx > bIdx;
        })
        .value(function (d) {
            return d.values;
        });

    var svg = d3.select("#" + idTagName).append("div")
        .classed("svg-container-pie", true) //container class to make it responsive
        .append("svg")
        //responsive SVG needs these 2 attributes and no width and height attr
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 0 " + width + " " + height)
        //class to make it responsive
        .classed("svg-content-responsive", true)
        //        .attr("width", width)
        //        .attr("height", height)
        .append("g")
        .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

    d3.csv(csvFileName, function (d) {
        return {
            weekday: d[weekdayColumnName],
            carrier: d.carrier,
            destination: d.destination,
            count: +d.n
        };
    }, function (error, data) {
        if (error) throw error;

        // group data by destination and weekday, then sum the counts
        var grouped = d3.nest()
            //                .key(function (d) { // return d.destination; // })
            .key(function (d) {
                return d.weekday;
            })
            .rollup(function (v) {
                return d3.sum(v, function (d) {
                    return d.count
                });
            })
            .entries(data);

        console.log(JSON.stringify(grouped));
        console.log(grouped[0].values);

        var g = svg.selectAll(".arc")
            //                .data(pie(grouped[0].values))
            .data(pie(grouped))
            .enter().append("g")
            .attr("class", "arc");

        g.append("path")
            .attr("d", arc)
            .style("fill", function (d) {
                return color(d.data.key);
            });

        g.append("text")
            .attr("transform", function (d) {
                return "translate(" + arc.centroid(d) + ")";
            })
            .attr("dy", ".35em")
            .text(function (d) {
                return d.data.key + " (" + d.data.values + ")";
            });
    });

}