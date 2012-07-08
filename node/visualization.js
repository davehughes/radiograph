(function() {

  this.include = function() {
    this.get({
      '/visualization/scatterplots': function() {
        return this.render('scatterplots', {
          scripts: ['/js/d3', '/js/underscore', '/scatterplots']
        });
      }
    });
    this.view({
      'scatterplots': function() {
        div({
          id: 'plot'
        });
        a('.btn.expand', function() {
          return 'Expand Scale';
        });
        return a('.btn.contract', function() {
          return 'Contract Scale';
        });
      }
    });
    return this.coffee({
      '/scatterplots.js': function() {
        return $(function() {
          var chart, data, dataPoints, gridLines, h, hLines, points, svg, vLines, w, x, xAxis, xAxisG, y, yAxis, yAxisG;
          w = 500;
          h = 500;
          svg = d3.select('#plot').append('svg:svg').attr('width', w).attr('height', h);
          chart = svg.append('rect').attr('x', 0.1 * svg.attr('width')).attr('y', 0).attr('width', 0.9 * svg.attr('width')).attr('height', 0.9 * svg.attr('height')).style('fill', 'white');
          x = d3.scale.linear();
          y = d3.scale.linear();
          xAxis = d3.svg.axis().scale(x).orient('bottom');
          yAxis = d3.svg.axis().scale(y).orient('left');
          x.range([parseInt(chart.attr('x')), parseInt(chart.attr('x')) + parseInt(chart.attr('width'))]);
          y.range([parseInt(chart.attr('y')) + parseInt(chart.attr('height')), chart.attr('y')]);
          xAxisG = svg.append('svg:g').call(xAxis).attr('transform', "translate(0, " + (0.9 * svg.attr('height')) + ")");
          yAxisG = svg.append('svg:g').call(yAxis).attr('transform', "translate(" + (0.1 * svg.attr('width')) + ", 0)");
          gridLines = svg.append('svg:g').attr('class', 'grid-lines').attr('transform', "translate(" + (0.1 * svg.attr('width')) + ", 0)");
          vLines = gridLines.append('svg:g').attr('class', 'vertical');
          vLines.selectAll('line').data(x.ticks(10)).enter().append('line').attr('x1', function(d) {
            return x(d);
          }).attr('x2', function(d) {
            return x(d);
          }).attr('y1', 0).attr('y2', chart.attr('height')).style('stroke', '#ccc').style('stroke-width', 0.5);
          hLines = gridLines.append('svg:g').attr('class', 'horizontal');
          hLines.selectAll('line.horizontal').data(y.ticks(10)).enter().append('line').attr('x1', 0).attr('x2', chart.attr('width')).attr('y1', function(d) {
            return y(d);
          }).attr('y2', function(d) {
            return y(d);
          }).style('stroke', '#ccc').style('stroke-width', 0.5);
          data = _.map(d3.range(20), function() {
            return {
              x: Math.random(),
              y: Math.random()
            };
          });
          dataPoints = svg.append('svg:g').attr('class', 'data-points');
          points = dataPoints.selectAll('circle').data(data);
          points.enter().append('svg:circle').attr('cx', function(d) {
            return x(d.x);
          }).attr('cy', function(d) {
            return y(d.y);
          }).attr('r', 3).style('stroke', 'black').style('fill', 'red');
          points.exit().remove();
          $('.expand').click(function() {
            x.domain([x.domain()[0] * 1.1, x.domain()[1] * 1.1]);
            xAxisG.transition().call(xAxis);
            y.domain([y.domain()[0] * 1.1, y.domain()[1] * 1.1]);
            yAxisG.transition().call(yAxis);
            return points.transition().attr('cx', function(d) {
              return x(d.x);
            }).attr('cy', function(d) {
              return y(d.y);
            });
          });
          return $('.contract').click(function() {
            x.domain([x.domain()[0] * 0.9, x.domain()[1] * 0.9]);
            xAxisG.transition().call(xAxis);
            y.domain([y.domain()[0] * 0.9, y.domain()[1] * 0.9]);
            yAxisG.transition().call(yAxis);
            return points.transition().attr('cx', function(d) {
              return x(d.x);
            }).attr('cy', function(d) {
              return y(d.y);
            });
          });
        });
      }
    });
  };

}).call(this);
