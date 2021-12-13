var margin = {top: 20, right: 20, bottom: 30, left: 60},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;


var svg = d3.select("#graph")
  .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform",
          "translate(" + margin.left + "," + margin.top + ")");

    /*https://raw.githubusercontent.com/zhining4/NYC-motor-accident/main/clean_data.csv*/    


d3.csv('https://raw.githubusercontent.com/zhining4/NYC-motor-accident/main/interactive.csv').then(function(data) {

    var parseTime = d3.timeParse("%Y-%m-%d");
    data.forEach(function(d) {
        d.time = parseTime(d.real_crash_date);
      });
  
    
    var startDate = d3.min(data, d=> d.time )
    var endDate =  d3.max(data, d=> d.time )

    var x = d3.scaleLinear()
            .domain([startDate,endDate])
            .range([ 0, width ]);
    svg.append("g")
      .attr("transform", "translate(0," + height + ")")
      .call(d3.axisBottom(x).tickFormat(d3.timeFormat("%m-%d")));

    var y = d3.scaleLinear()
            .domain([0, 0.5])
            .range([ height, 0 ]);
    svg.append("g")
      .call(d3.axisLeft(y));

  
    var periods = ["morning","noon","afternoon","evening","midnight"]; 

  
    d3.select("#dayPeriod")
        .selectAll('myOptions')
        .data(periods)
        .enter()
        .append('option')
        .text(d => d) 
        .attr("value", d=>d); 

 
    var myColor = d3.scaleOrdinal()
        .domain(periods)
        .range(d3.schemeSet1);


    var line = svg
        .append('g')
        .append("path")
        .datum(data.filter( d => d.day_period==periods[0]))
        .attr("d", d3.line()
            .x(d => x(d.time) )
            .y(d => y(d.freq) )
        )
        .attr("stroke", myColor("valueC"))
        .style("stroke-width", 5)
        .style("fill", "none")

    function update(period) {

        var dataFilter = data.filter( d=> d.day_period==period)

        line
            .datum(dataFilter)
            .transition()
            .duration(1000)
            .attr("d", d3.line()
            .x(d => x(d.time) )
            .y(d => y(d.freq) )
            )
            .attr("stroke",  myColor(period) )
    }


    d3.select("#dayPeriod").on("change", function(d) {
   
        var selectedOption = d3.select(this).property("value")

        update(selectedOption)
    })

})

