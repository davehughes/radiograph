@include = ->
  @get '/visualization/scatterplots': ->
    @render 'scatterplots',
      scripts: ['/js/d3', '/js/underscore', '/scatterplots']

  @view 'scatterplots': ->
    div id: 'plot'
    a '.btn.expand', -> 'Expand Scale'
    a '.btn.contract', -> 'Contract Scale'

  @coffee '/scatterplots.js': -> $ ->
    w = 500
    h = 500
    
    svg = d3.select('#plot')
      .append('svg:svg')
      .attr('width', w)
      .attr('height', h)

    chart = svg.append('rect')
      .attr('x', 0.1 * svg.attr('width'))
      .attr('y', 0)
      .attr('width', 0.9 * svg.attr('width'))
      .attr('height', 0.9 * svg.attr('height'))
      .style('fill', 'white')
    
    # Create and configure axes
    x = d3.scale.linear()
    y = d3.scale.linear()
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left')

    # Set up ranges
    x.range([parseInt(chart.attr('x')), parseInt(chart.attr('x')) + parseInt(chart.attr('width'))])
    y.range([parseInt(chart.attr('y')) + parseInt(chart.attr('height')), chart.attr('y')])

    xAxisG = svg.append('svg:g')
      .call(xAxis)
      .attr('transform', "translate(0, #{0.9 * svg.attr('height')})")

    yAxisG = svg.append('svg:g')
      .call(yAxis)
      .attr('transform', "translate(#{0.1 * svg.attr('width')}, 0)")
    
    # Add grid lines
    gridLines = svg.append('svg:g')
      .attr('class', 'grid-lines')
      .attr('transform', "translate(#{0.1 * svg.attr('width')}, 0)")

    vLines = gridLines.append('svg:g')
      .attr('class', 'vertical')
    vLines.selectAll('line')
      .data(x.ticks(10))
      .enter().append('line')
        .attr('x1', (d) -> x(d))
        .attr('x2', (d) -> x(d))
        .attr('y1', 0)
        .attr('y2', chart.attr('height'))
        .style('stroke', '#ccc')
        .style('stroke-width', 0.5)

    hLines = gridLines.append('svg:g')
      .attr('class', 'horizontal')
    hLines.selectAll('line.horizontal')
      .data(y.ticks(10))
      .enter().append('line')
        .attr('x1', 0)
        .attr('x2', chart.attr('width'))
        .attr('y1', (d) -> y(d))
        .attr('y2', (d) -> y(d))
        .style('stroke', '#ccc')
        .style('stroke-width', 0.5)

    data = _.map d3.range(20), -> x: Math.random(), y: Math.random()
    dataPoints = svg.append('svg:g').attr('class', 'data-points')
    points = dataPoints.selectAll('circle')
      .data(data)

    points
      .enter().append('svg:circle')
        .attr('cx', (d) -> x(d.x))
        .attr('cy', (d) -> y(d.y))
        .attr('r', 3)
        .style('stroke', 'black')
        .style('fill', 'red')
        # .on('click', (d) -> console.log d)

    points
      .exit().remove()

    $('.expand').click ->
      x.domain([x.domain()[0] * 1.1, x.domain()[1] * 1.1])
      xAxisG.transition().call(xAxis)
      y.domain([y.domain()[0] * 1.1, y.domain()[1] * 1.1])
      yAxisG.transition().call(yAxis)
      points.transition()
        .attr('cx', (d) -> x(d.x))
        .attr('cy', (d) -> y(d.y))

    $('.contract').click ->
      x.domain([x.domain()[0] * 0.9, x.domain()[1] * 0.9])
      xAxisG.transition().call(xAxis)
      y.domain([y.domain()[0] * 0.9, y.domain()[1] * 0.9])
      yAxisG.transition().call(yAxis)
      points.transition()
        .attr('cx', (d) -> x(d.x))
        .attr('cy', (d) -> y(d.y))
