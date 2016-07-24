// Fix map for IE
if (!('map' in Array.prototype)) {
    Array.prototype.map = function (mapper, that /*opt*/ ) {
        var other = new Array(this.length);
        for (var i = 0, n = this.length; i < n; i++)
            if (i in this)
                other[i] = mapper.call(that, this[i], i, this);
        return other;
    };
};

var browser = BrowserDetect;

if (isOldBrowser()) {
    $('#old_browser_msg').show();
    $('#wtf').hide();
    $('fieldset#state').addClass('ff3');
    $('#ie8_percents').addClass('ff3');
    $('#share2').addClass('ff3');
    $('#poweredby.old_browsers').show();
}

var buckets = 7, // was 11
    colorScheme = 'grn',
    days = [
        {
            name: 'Monday',
            abbr: 'Mo'
        },
        {
            name: 'Tuesday',
            abbr: 'Tu'
        },
        {
            name: 'Wednesday',
            abbr: 'We'
        },
        {
            name: 'Thursday',
            abbr: 'Th'
        },
        {
            name: 'Friday',
            abbr: 'Fr'
        },
        {
            name: 'Saturday',
            abbr: 'Sa'
        },
        {
            name: 'Sunday',
            abbr: 'Su'
        }
	],
    types = {
        all: 'All',
        pc: 'Computer',
        mob: 'Mobile'
    },
    hours = ['12a', '1a', '2a', '3a', '4a', '5a', '6a', '7a', '8a', '9a', '10a', '11a', '12p', '1p', '2p', '3p', '4p', '5p', '6p', '7p', '8p', '9p', '10p', '11p'],
    stateAbbrs = ['all', 'AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 'WI', 'WV', 'WY'],
    states = {
        all: {
            name: 'All States',
            abbr: 'all',
            offset: 0
        },
        AK: {
            name: 'Alaska',
            abbr: 'AK',
            offset: -1
        },
        AL: {
            name: 'Alabama',
            abbr: 'AL',
            offset: 2
        },
        AR: {
            name: 'Arkansas',
            abbr: 'AR',
            offset: 2
        },
        AZ: {
            name: 'Arizona',
            abbr: 'AZ',
            offset: 0
        },
        CA: {
            name: 'California',
            abbr: 'CA',
            offset: 0
        },
        CO: {
            name: 'Colorado',
            abbr: 'CO',
            offset: 1
        },
        CT: {
            name: 'Connecticut',
            abbr: 'CT',
            offset: 3
        },
        DC: {
            name: 'Washington D.C.',
            abbr: 'DC',
            offset: 3
        },
        DE: {
            name: 'Delaware',
            abbr: 'DE',
            offset: 3
        },
        FL: {
            name: 'Florida',
            abbr: 'FL',
            offset: 3
        },
        GA: {
            name: 'Georgia',
            abbr: 'GA',
            offset: 3
        },
        HI: {
            name: 'Hawaii',
            abbr: 'HI',
            offset: -3
        },
        IA: {
            name: 'Iowa',
            abbr: 'IA',
            offset: 2
        },
        ID: {
            name: 'Idaho',
            abbr: 'ID',
            offset: 1
        },
        IL: {
            name: 'Illinois',
            abbr: 'IL',
            offset: 2
        },
        IN: {
            name: 'Indiana',
            abbr: 'IN',
            offset: 3
        },
        KS: {
            name: 'Kansas',
            abbr: 'KS',
            offset: 2
        },
        KY: {
            name: 'Kentucky',
            abbr: 'KY',
            offset: 3
        },
        LA: {
            name: 'Louisiana',
            abbr: 'LA',
            offset: 2
        },
        MA: {
            name: 'Massachusetts',
            abbr: 'MA',
            offset: 3
        },
        MD: {
            name: 'Maryland',
            abbr: 'MD',
            offset: 3
        },
        ME: {
            name: 'Maine',
            abbr: 'ME',
            offset: 3
        },
        MI: {
            name: 'Michigan',
            abbr: 'MI',
            offset: 3
        },
        MN: {
            name: 'Minnesota',
            abbr: 'MN',
            offset: 2
        },
        MO: {
            name: 'Missouri',
            abbr: 'MO',
            offset: 2
        },
        MS: {
            name: 'Missippippi',
            abbr: 'MS',
            offset: 2
        },
        MT: {
            name: 'Montana',
            abbr: 'MT',
            offset: 1
        },
        NC: {
            name: 'North Carolina',
            abbr: 'NC',
            offset: 3
        },
        ND: {
            name: 'North Dakota',
            abbr: 'ND',
            offset: 2
        },
        NE: {
            name: 'Nebraska',
            abbr: 'NE',
            offset: 2
        },
        NH: {
            name: 'New Hampshire',
            abbr: 'NH',
            offset: 3
        },
        NJ: {
            name: 'New Jersey',
            abbr: 'NJ',
            offset: 3
        },
        NM: {
            name: 'New Mexico',
            abbr: 'NM',
            offset: 1
        },
        NV: {
            name: 'Nevada',
            abbr: 'NV',
            offset: 0
        },
        NY: {
            name: 'New York',
            abbr: 'NY',
            offset: 3
        },
        OH: {
            name: 'Ohio',
            abbr: 'OH',
            offset: 3
        },
        OK: {
            name: 'Oklahoma',
            abbr: 'OK',
            offset: 2
        },
        OR: {
            name: 'Oregon',
            abbr: 'OR',
            offset: 0
        },
        PA: {
            name: 'Pennsylvania',
            abbr: 'PA',
            offset: 3
        },
        RI: {
            name: 'Rhode Island',
            abbr: 'RI',
            offset: 3
        },
        SC: {
            name: 'South Carolina',
            abbr: 'SC',
            offset: 3
        },
        SD: {
            name: 'South Dakota',
            abbr: 'SD',
            offset: 2
        },
        TN: {
            name: 'Tennessee',
            abbr: 'TN',
            offset: 2
        },
        TX: {
            name: 'Texas',
            abbr: 'TX',
            offset: 2
        },
        UT: {
            name: 'Utah',
            abbr: 'UT',
            offset: 1
        },
        VA: {
            name: 'Virginia',
            abbr: 'VA',
            offset: 3
        },
        VT: {
            name: 'Vermont',
            abbr: 'VT',
            offset: 3
        },
        WA: {
            name: 'Washington',
            abbr: 'WA',
            offset: 0
        },
        WI: {
            name: 'Wisconsin',
            abbr: 'WI',
            offset: 2
        },
        WV: {
            name: 'West Virginia',
            abbr: 'WV',
            offset: 3
        },
        WY: {
            name: 'Wyoming',
            abbr: 'WY',
            offset: 1
        }
    };

var data;
var ffvData;

var deltaTimes;
var departureDates;

//if (isOldBrowser() === false) {
//	createMap();
//}
//addStateButtons();
var dateParser = d3.time.format("%Y-%m-%d");

var descendingIntStrings = function (a, b) {
    a = parseInt(a);
    b = parseInt(b);
    return b < a ? -1 : b > a ? 1 : b >= a ? 0 : NaN;
};

var ascendingDateStrings = function (a, b) {
    a = dateParser.parse(a);
    b = dateParser.parse(b);
    return d3.ascending(a, b);
};

d3.select('#vis').classed(colorScheme, true);

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

    var nestedData = d3.nest()
        .key(function (d) {
            return d.carrier;
        })
        .key(function (d) {
            return d.departureDate;
        }).sortKeys(ascendingDateStrings)
        .key(function (d) {
            return d.deltaTime;
        }).sortKeys(descendingIntStrings)
        .entries(data);

    // rearrange nested data so that the first level is an object and not an array
    ffvData = new Object();
    nestedData.forEach(function (v) {
        ffvData[v.key] = v.values;
    });
    console.log(ffvData);

    deltaTimes = d3.map(data,
        function (d) {
            return d.deltaTime;
        }).keys();
    // map into array with ints instead of Strings (keys() of map returns Strings)
    deltaTimes = $.map(deltaTimes, function (value, index) {
        return [parseInt(value)];
    });
    deltaTimes.sort(d3.descending);
    console.log(deltaTimes);


    //    var tmpDepartureDates = data.map(
    //        function (d) {
    //            return {
    //                name: d.departureDate,
    //                abbr: d.departureDate.split("-")[2] + "." + d.departureDate.split("-")[1]
    //            };
    //        });
    //    console.log(tmpDepartureDates);

    departureDates = d3.map(data,
        function (d) {
            return d.departureDate;
            //            return d.departureDate.split("-")[2] + "." + d.departureDate.split("-")[1];
        }).keys();

    // map into array with ints instead of Strings (keys() of map returns Strings)
    departureDates = $.map(departureDates, function (value, index) {
        return [{
            date: dateParser.parse(value),
            name: value,
            abbr: value.split("-")[2] + "." + value.split("-")[1]
        }];
    });
    departureDates.sort(function (a, b) {
        return d3.ascending(a.date, b.date);
    });
    console.log(departureDates);



    createPriceTiles();
    //    createTiles();
    reColorPriceTiles('AB', 'AB');
});

//d3.json('tru247.json', function (json) {
//
//    data = json;
//
//    createTiles();
//    reColorTiles('all', 'all');
//
//    if (isOldBrowser() === false) {
//        drawMobilePie('all');
//    }
//
//    /* ************************** */
//
//    // State map click events
//    //    d3.selectAll('#map path.state').on('click', function () {
//    //        var $sel = d3.select('path.state.sel'),
//    //            prevState, currState;
//    //
//    //        if ($sel.empty()) {
//    //            prevState = '';
//    //        } else {
//    //            prevState = $sel.attr('id');
//    //        }
//    //
//    //        currState = d3.select(this).attr('id');
//    //
//    //        if (prevState !== currState) {
//    //            var type = d3.select('#type label.sel span').attr('class');
//    //            reColorTiles(currState, type);
//    //            drawMobilePie(currState);
//    //        }
//    //
//    //        d3.selectAll('#map path.state').classed('sel', false);
//    //        d3.select(this).classed('sel', true);
//    //        d3.select('#show_all_states').classed('sel', false);
//    //        d3.select('#wtf h2').html(states[currState].name);
//    //        d3.select('fieldset#state label.sel').classed('sel', false);
//    //        d3.select('fieldset#state label[for="state_' + currState + '"]').classed('sel', true);
//    //    });
//
//    /* ************************** */
//
//    // All, PC, Mobile control event listener
//    $('input[name="type"]').change(function () {
//
//        var type = $(this).val(),
//            $sel = d3.select('#map path.state.sel');
//
//        d3.selectAll('fieldset#type label').classed('sel', false);
//        d3.select('label[for="type_' + type + '"]').classed('sel', true);
//
//        if ($sel.empty()) {
//            var state = 'all';
//        } else {
//            var state = $sel.attr('id');
//        }
//
//        reColorTiles(state, type);
//        d3.select('#pc2mob').attr('class', type);
//
//        var type = types[selectedType()];
//        d3.select('#wtf .subtitle').html(type + ' traffic daily');
//    });
//
//    /* ************************** */
//
//    // All States click
//    $('label[for="state_all"]').click(function () {
//
//        d3.selectAll('fieldset#state label').classed('sel', false);
//        $(this).addClass('sel');
//        var type = d3.select('input[name="type"]').property('value');
//
//        d3.selectAll('#map path.state').classed('sel', false);
//
//        reColorTiles('all', type);
//        drawMobilePie('all');
//
//        d3.select('#wtf h2').html('All States');
//    });
//
//    /* ************************** */
//
//    // Text States list event listener
//    $('input[name="state"]').change(function () {
//
//        var state = $(this).val(),
//            type = d3.select('input[name="type"]').property('value');
//
//        d3.selectAll('fieldset#state label').classed('sel', false);
//        d3.select('label[for="state_' + state + '"]').classed('sel', true);
//
//        reColorTiles(state, type);
//        updateIE8percents(state);
//    });
//
//    /* ************************** */
//
//    // tiles mouseover events
//    $('#tiles td').hover(function () {
//
//        $(this).addClass('sel');
//
//        var tmp = $(this).attr('id').split('d').join('').split('h'),
//            day = parseInt(tmp[0]),
//            hour = parseInt(tmp[1]);
//
//        var $sel = d3.select('#map path.state.sel');
//
//        if ($sel.empty()) {
//            var state = 'all';
//        } else {
//            var state = $sel.attr('id');
//        }
//
//        var view = 'all';
//
//        if (isOldBrowser() === false) {
//            drawHourlyChart(state, day);
//            selectHourlyChartBar(hour);
//        }
//
//        var type = types[selectedType()];
//        d3.select('#wtf .subtitle').html(type + ' traffic on ' + days[day].name + 's');
//
//    }, function () {
//
//        $(this).removeClass('sel');
//
//        var $sel = d3.select('#map path.state.sel');
//
//        if ($sel.empty()) {
//            var state = 'all';
//        } else {
//            var state = $sel.attr('id');
//        }
//        if (isOldBrowser() === false) {
//            drawHourlyChart(state, 3);
//        }
//        var type = types[selectedType()];
//        d3.select('#wtf .subtitle').html(type + ' traffic daily');
//    });
//});

/* ************************** */

function isOldBrowser() {

    var result = false;
    if (browser.browser === 'Explorer' && browser.version < 9) {
        result = true;
    } else if (browser.browser === 'Firefox' && browser.version < 4) {
        result = true;
    }

    //console.log(result);

    return result;
}


/* ************************** */

function selectedType() {

    //return d3.select('input[name="type"]:checked').property('value'); // IE8 doesn't like this
    return $('input[name="type"]:checked').val();
}

/* ************************** */

function addStateButtons() {

    for (var i = 1; i < stateAbbrs.length; i++) {
        var abbr = stateAbbrs[i];
        var html = '<input type="radio" id="state_' + abbr + '" name="state" value="' + abbr + '"/><label for="state_' + abbr + '"><span class="' + abbr + '">' + abbr + '</span></label>';

        $('fieldset#state').append(html);
    }
}

/* ************************** */

function reColorPriceTiles(state, view) {
    var side = d3.select('#tiles').attr('class');

    if (side === 'front') {
        side = 'back';
    } else {
        side = 'front';
    }

    //    console.log(ffvData[state].length);
    for (var d = 0; d < ffvData[state].length; d++) {
        for (var h = 0; h < ffvData[state][d].values.length; h++) {
            var sel = '#d' + d + 'h' + h + ' .tile .' + side;
            // TODO: hier gibt es mehr als 1 flug pro tag!!!
            //            console.log(ffvData[state][d].values[h]);
            var val = ffvData[state][d].values[h].values[0].price;
            var bucket = ffvData[state][d].values[h].values[0].bin;

            if (view !== 'all') {
                val = ffvData[state][d].values[h].values[0].price;
            }

            // erase all previous bucket designations on this cell
            for (var i = 1; i <= buckets; i++) {
                var cls = 'q' + i + '-' + buckets;
                d3.select(sel).classed(cls, false);
            }

            // set new bucket designation for this cell
            var cls = 'q' + (val > 0 ? bucket : 0) + '-' + buckets;
            d3.select(sel).classed(cls, true);
        }
    }
    flipTiles();
    //    if (isOldBrowser() === false) {
    //        drawHourlyChart(state, 3);
    //    }
}

/* ************************** */

function flipTiles() {

    var oldSide = d3.select('#tiles').attr('class'),
        newSide = '';

    if (oldSide == 'front') {
        newSide = 'back';
    } else {
        newSide = 'front';
    }

    var flipper = function (h, d, side) {
        return function () {
            var sel = '#d' + d + 'h' + h + ' .tile',
                rotateY = 'rotateY(180deg)';

            if (side === 'back') {
                rotateY = 'rotateY(0deg)';
            }
            if (browser.browser === 'Safari' || browser.browser === 'Chrome') {
                d3.select(sel).style('-webkit-transform', rotateY);
            } else {
                d3.select(sel).select('.' + oldSide).classed('hidden', true);
                d3.select(sel).select('.' + newSide).classed('hidden', false);
            }

        };
    };

    for (var h = 0; h < deltaTimes.length; h++) {
        for (var d = 0; d < departureDates.length; d++) {
            var side = d3.select('#tiles').attr('class');
            setTimeout(flipper(h, d, side), (h * 20) + (d * 20) + (Math.random() * 100));
        }
    }
    d3.select('#tiles').attr('class', newSide);
}

/* ************************** */

function drawHourlyChart(state, day) {

    d3.selectAll('#hourly_values svg').remove();

    var w = 300,
        h = 150;

    var weeklyData = data[state].views[day],
        view = d3.select('#type label.sel span').attr('class');


    var y = d3.scale.linear()
        .domain([0, d3.max(weeklyData, function (d) {
            return (view === 'all') ? d.pc + d.mob : d[view]
        })])
        .range([0, h]);


    var chart = d3.select('#hourly_values .svg')
        .append('svg:svg')
        .attr('class', 'chart')
        .attr('width', 300)
        .attr('height', 170);

    var rect = chart.selectAll('rect'),
        text = chart.selectAll('text');

    rect.data(weeklyData)
        .enter()
        .append('svg:rect')
        .attr('x', function (d, i) {
            return i * 12;
        })
        .attr('y', function (d) {
            return (view === 'all') ? h - y(d.pc + d.mob) : h - y(d[view])
        })
        .attr('height', function (d) {
            return (view === 'all') ? y(d.pc + d.mob) : y(d[view])
        })
        .attr('width', 10)
        .attr('class', function (d, i) {
            return 'hr' + i
        });

    text.data(hours)
        .enter()
        .append('svg:text')
        .attr('class', function (d, i) {
            return (i % 3) ? 'hidden hr' + i : 'visible hr' + i
        })
        .attr("x", function (d, i) {
            return i * 12
        })
        .attr("y", 166)
        .attr("text-anchor", 'left')
        .text(String);
}

/* ************************** */

function drawMobilePie(state) {

    var w = 150,
        h = 150,
        r = Math.min(w, h) / 2,
        pieData = [1, data[state].pc2mob],
        pie = d3.layout.pie(),
        arc = d3.svg.arc().innerRadius(0).outerRadius(r),
        type = selectedType();

    d3.select('#pc2mob').attr('class', type);
    d3.selectAll('#pc2mob svg').remove();

    var chart = d3.select("#pc2mob .svg").append('svg:svg')
        .data([pieData])
        .attr("width", w)
        .attr("height", h);

    var arcs = chart.selectAll('g')
        .data(pie)
        .enter().append('svg:g')
        .attr("transform", "translate(" + r + "," + r + ")");

    arcs.append('svg:path')
        .attr('d', arc)
        .attr('class', function (d, i) {
            return i === 0 ? 'mob' : 'pc'
        });

    var rawMobPercent = 100 / (data[state].pc2mob + 1);

    if (rawMobPercent < 1) {
        var mobPercent = '< 1',
            pcPercent = '> 99';
    } else {
        var mobPercent = Math.round(rawMobPercent),
            pcPercent = 100 - mobPercent;
    }

    d3.select('#pc2mob .pc span').html(pcPercent + '%');
    d3.select('#pc2mob .mob span').html(mobPercent + '%');

    var html = d3.select('#pc2mob ul').html();
    d3.select('#ie8_percents').html(html);
}

/* ************************** */

function updateIE8percents(state) {

    var rawMobPercent = 100 / (data[state].pc2mob + 1);

    if (rawMobPercent < 1) {
        var mobPercent = '< 1',
            pcPercent = '> 99';
    } else {
        var mobPercent = Math.round(rawMobPercent),
            pcPercent = 100 - mobPercent;
    }

    d3.select('#pc2mob .pc span').html(pcPercent + '%');
    d3.select('#pc2mob .mob span').html(mobPercent + '%');

    var html = d3.select('#pc2mob ul').html();
    d3.select('#ie8_percents').html(html);
}




/* ************************** */

function createTiles() {

    var html = '<table id="tiles" class="front">';

    html += '<tr><th><div>&nbsp;</div></th>';

    for (var h = 0; h < hours.length; h++) {
        html += '<th class="h' + h + '">' + hours[h] + '</th>';
    }

    html += '</tr>';

    for (var d = 0; d < days.length; d++) {
        html += '<tr class="d' + d + '">';
        html += '<th>' + days[d].abbr + '</th>';
        for (var h = 0; h < hours.length; h++) {
            html += '<td id="d' + d + 'h' + h + '" class="d' + d + ' h' + h + '"><div class="tile"><div class="face front"></div><div class="face back"></div></div></td>';
        }
        html += '</tr>';
    }

    html += '</table>';
    d3.select('#vis').html(html);
}

function createPriceTiles() {

    var html = '<table id="tiles" class="front">';

    html += '<tr><th><div>&nbsp;</div></th>';

    for (var h = 0; h < deltaTimes.length; h++) {
        html += '<th class="h' + h + '">' + deltaTimes[h] + '</th>';
    }

    html += '</tr>';

    for (var d = 0; d < departureDates.length; d++) {
        html += '<tr class="d' + d + '">';
        html += '<th>' + departureDates[d].abbr + '</th>';
        for (var h = 0; h < deltaTimes.length; h++) {
            html += '<td id="d' + d + 'h' + h + '" class="d' + d + ' h' + h + '"><div class="tile"><div class="face front"></div><div class="face back"></div></div></td>';
        }
        html += '</tr>';
    }

    html += '</table>';
    d3.select('#vis').html(html);
}

/* ************************** */

function selectHourlyChartBar(hour) {

    d3.selectAll('#hourly_values .chart rect').classed('sel', false);
    d3.selectAll('#hourly_values .chart rect.hr' + hour).classed('sel', true);

    d3.selectAll('#hourly_values .chart text').classed('hidden', true);
    d3.selectAll('#hourly_values .chart text.hr' + hour).classed('hidden', false);

};

/* ************************** */

function createMap() {
    var svg = d3.select("#map").append('svg:svg')
        .attr('width', 320)
        .attr('height', 202);

    var g = svg.append('svg:g')
        .attr('transform', 'scale(0.5) translate(-27, -134)');

    for (s = 0; s < mapSVG.states.length; s++) {
        var state = mapSVG.states[s];

        var path = g.append('svg:path')
            .attr('id', state)
            .attr('class', 'state')
            .attr('d', mapSVG[state]);
    }
}