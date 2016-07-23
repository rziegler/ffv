d3.csv("data/data-mad.csv", function (d) {
    return {
        destination: d.destination,
        origin: d.origin,
        carrier: d.carrier,
        flightNumber: d.flightNumber,
        departureDate: d.departureDate,
        requestDate: d.requestDate,
        deltaTime: +d.deltaTime,
        price: +d.pmin,
        bin: +d.binRanked
    };
}, function (error, data) {
    if (error) throw error;

    var ffvData = d3.nest()
        .key(function (d) {
            return d.carrier;
        })
        .key(function (d) {
            return d.departureDate;
        })
        .key(function (d) {
            return d.deltaTime;
        })
        .map(data);

    var ffvData2 = d3.nest()
        .key(function (d) {
            return d.carrier;
        })
        .key(function (d) {
            return d.departureDate;
        })
        .key(function (d) {
            return d.deltaTime;
        })
        .entries(data);

    var ffvData3 = d3.nest()
        .key(function (d) {
            return d.carrier;
        })
        .key(function (d) {
            return d.departureDate;
        })
        .key(function (d) {
            return d.deltaTime;
        })
        .map(data, d3.map);

    console.log(ffvData);
    console.log(ffvData2);
    console.log(ffvData2.length);

    var filterValue = "AB";
    var ffvAB = ffvData2.filter(function (v, filterValue) {
        return v.key === filterValue;
    });
    console.log(ffvAB.length);

    var r = new Object();
    ffvData2.forEach(function (v) {
            r[v.key] = v.values;
        }

    );

    console.log(r);

    //    console.log(ffvData3);

});