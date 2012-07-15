@include = ->
  @get '/visualization', ->
    @render 'plots',
      scripts: [
        '/js/underscore'
        '/js/d3'
        # '/js/nv.d3.min'
        '/js/fisheye.d3'
        '/js/nv.d3'
        '/n3plots'
      ]
      stylesheets: [
        '/css/nv.d3'
      ]

  @view 'plots': ->
    div id: 'multiscatter', ->
      svg style: 'height: 500px; width: 500px;'

    div id: 'scatterplot', ->
      svg style: 'height: 500px; width: 500px;'

    span 'X Axis: ', ->
      select id: 'x-axis', ->
        option -> '1'
        option -> '2'
        option -> '3'
        option -> '4'
        option -> '5'

    span 'Y Axis: ', ->
      select id: 'y-axis', ->
        option -> '1'
        option -> '2'
        option -> '3'
        option -> '4'
        option -> '5'

    a '.btn.expand', -> 'Expand Scale'
    a '.btn.contract', -> 'Contract Scale'

    div id: 'distribution-plot'

    table ->
      tr ->
        th -> 'Skull Length'
      tr ->
        th -> 'Cranial Width'
      tr ->
        th -> 'Neurocranial Height'
      tr ->
        th -> 'Facial Height'
      tr ->
        th -> 'Palate Length'
      tr ->
        th -> 'Palate Width'
      tr ->
        th ->
        th -> 'Skull Length'
        th -> 'Cranial Width'
        th -> 'Neurocranial Height'
        th -> 'Facial Height'
        th -> 'Palate Length'
        th -> 'Palate Width'


  @coffee '/n3plots.js': -> $ ->
    nv.addGraph ->
      chart = nv.models.scatterChart()
        .color(d3.scale.category10().range())
        .showControls(false)
        .showLegend(false)
        .showDistX(false)
        .showDistY(false)

      chart.xAxis.tickFormat(d3.format('.02f'))
      chart.yAxis.tickFormat(d3.format('.02f'))

      d3.select('#scatterplot svg')
        .datum(randomData(4, 40))
        .transition()
          .duration(500)
          .call(chart)

      nv.utils.windowResize(chart.update)
      return chart

    randomData = (groups, points) ->
      shapes = ['circle', 'square', 'diamond', 'cross', 'triangle-up', 'triangle-down']
      random = d3.random.normal()

      _.map _.range(groups), (idx) ->
        key: "Group #{idx}"
        values: _.map(_.range(points), ->
          x: random()
          y: random()
          size: 10
          shape: shapes[idx % 6]
        )

  @coffee '/multiscatter.js': -> $ ->
    vars = [
      { key: 'skull_length', label: 'Skull Length' }
      { key: 'cranial_width', label: 'Cranial Width' }
      { key: 'neurocranial_height', label: 'Neurocranial Height' }
      { key: 'facial_height', label: 'Facial Height' }
      { key: 'palate_length', label: 'Palate Length' }
      { key: 'palate_width', label: 'Palate Width' }
    ]

    x = d3.scale.ordinal()
    x.domain(_.pluck(vars, 'label'))
    y = d3.scale.ordinal()
    x.domain(_.pluck(vars, 'label'))

    chart = d3.select('#multiscatter svg')

  @coffee '/plots.js': -> $ ->
    data = _.map d3.range(500), -> _.map d3.range(5), Math.random

    scatterplot = ->
        w = 500
        h = 500

        svg = d3.select('#scatterplot')
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

        voronoiGroup = svg.append('svg:g').attr('class', 'voronoi-polygons')

        dataPoints = svg.append('svg:g').attr('class', 'data-points')
        points = dataPoints.selectAll('circle').data(data)

        xVar = 0
        yVar = 1
        $('select#x-axis').change (e) ->
          xVar = parseInt($(e.currentTarget).val()) - 1
          updateVars()

        $('select#y-axis').change (e) ->
          yVar = parseInt($(e.currentTarget).val()) - 1
          updateVars()

        points
          .enter().append('svg:circle')
            .attr('cx', (d) -> x(d[xVar]))
            .attr('cy', (d) -> y(d[yVar]))
            .attr('r', 3)
            .style('stroke', 'black')
            .style('fill', 'red')
            .on('mouseover', (d) ->
              d3.select(@).transition()
                .style('fill', 'blue')
                .attr('r', 10)
                .style('stroke-width', 4)
                )
            .on('mouseout', (d) ->
              d3.select(@).transition()
                .style('fill', 'red')
                .attr('r', 3)
                .style('stroke-width', 1)
                )

        points
          .exit().remove()

        updateVars = ->
          updateScale()
          voronoiGroup.selectAll('polygon').remove()
          voronoiData = d3.geom.voronoi(_.map data, (d) -> [x(d[xVar]), y(d[yVar])])
          voronoiShapes = voronoiGroup.selectAll('polygon').data(voronoiData)
          voronoiShapes.enter().append('svg:polygon')
            .attr('points', (d) -> _.map(d, (p) -> "#{p[0]},#{p[1]}").join(' '))
            .on('mouseover', -> d3.select(@).style('fill', 'green'))
            .on('mouseout', -> d3.select(@).style('fill', 'none'))
            .on('mousemove', (d) ->
              console.log 'mousemove'
            )


        distance = ([x1, y1], [x2, y2]) ->
          xdiff = x2 - x1
          ydiff = y2 - y1
          Math.sqrt(xdiff * xdiff + ydiff * ydiff)

        # Test out point highlight
        highlightPt = svg.append('svg:g')
          .attr('class', 'highlight-point')
          .attr('transform', 'translate(250, 250) scale(2)')

        testPoint = highlightPt.append('svg:circle')
          .attr('r', 10)
          .style('fill', 'blue')

        testHalo = highlightPt.append('svg:circle')
          .attr('r', 20)
          .style('fill', 'none')
          .style('stroke-width', 1)
          .style('stroke', 'black')

        updateScale = ->
          xAxisG.transition().call(xAxis)
          yAxisG.transition().call(yAxis)
          points.transition()
            .attr('cx', (d) -> x(d[xVar]))
            .attr('cy', (d) -> y(d[yVar]))

        $('.expand').click ->
          x.domain([x.domain()[0] * 1.1, x.domain()[1] * 1.1])
          y.domain([y.domain()[0] * 1.1, y.domain()[1] * 1.1])
          updateScale()

        $('.contract').click ->
          x.domain([x.domain()[0] * 0.9, x.domain()[1] * 0.9])
          y.domain([y.domain()[0] * 0.9, y.domain()[1] * 0.9])
          updateScale()

        updateVars()

    distributionPlot = ->

        # Process and bucket data
        varkey = 0
        numBuckets = 20
        buckets = []
        scale = d3.scale.linear()
        scale.domain([0, 1]).range([0, 1])
        bucketSize = scale(1.0 / numBuckets)

        _.each d3.range(numBuckets), (idx) ->
          buckets[idx] = 0

        _.each data, (d) ->
          idx = Math.floor(scale(d[varkey]) / bucketSize)
          buckets[idx] += 1

        w = 500
        h = 500

        svg = d3.select('#distribution-plot')
          .append('svg:svg')
          .attr('width', w)
          .attr('height', h)

        chart = svg.append('rect')
          .attr('x', 0.1 * svg.attr('width'))
          .attr('y', 0)
          .attr('width', 0.9 * svg.attr('width'))
          .attr('height', 0.9 * svg.attr('height'))
          .style('fill', 'green')

        # Create and configure axes
        x = d3.scale.linear()
        y = d3.scale.linear()
        xAxis = d3.svg.axis().scale(x).orient('bottom')
        yAxis = d3.svg.axis().scale(y).orient('left')

        # Set up ranges
        x.domain(d3.extent(data[varkey]))
        x.range([parseInt(chart.attr('x')), parseInt(chart.attr('x')) + parseInt(chart.attr('width'))])
        y.domain([0, d3.extent(buckets)[1]])
        y.range([chart.attr('y'), parseInt(chart.attr('y')) + parseInt(chart.attr('height'))])

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

        # Set up bars
        barWidth = chart.attr('width') / numBuckets
        dataBars = svg.append('svg:g')
          .attr('class', 'data-bars')
          .attr('transform', "translate(#{0.1 * svg.attr('width')}, #{0.9 * svg.attr('height')})")
        bars = dataBars.selectAll('rect').data(buckets)
        bars.enter().append('rect')
          .attr('x', (d, i) -> i * barWidth)
          .attr('y', 0)
          .attr('width', barWidth)
          .attr('height', (d) ->
            console.log "#{d} -> #{y(d)}"
            y(d))
          .attr('transform', 'scale(1, -1)') # flip vertically
          .style('stroke', 'black')
          .style('fill', 'red')

        bars.exit().remove()

        updateScale = ->
          xAxisG.transition().call(xAxis)
          yAxisG.transition().call(yAxis)
          points.transition()
            .attr('cx', (d) -> x(d[xVar]))
            .attr('cy', (d) -> y(d[yVar]))

    scatterplot()
    distributionPlot()

