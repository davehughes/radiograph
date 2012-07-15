(function() {

  this.include = function() {
    this.get('/visualization', function() {
      return this.render('plots', {
        scripts: ['/js/underscore', '/js/d3', '/js/fisheye.d3', '/js/nv.d3', '/n3plots'],
        stylesheets: ['/css/nv.d3']
      });
    });
    this.view({
      'plots': function() {
        div({
          id: 'multiscatter'
        }, function() {
          return svg({
            style: 'height: 500px; width: 500px;'
          });
        });
        div({
          id: 'scatterplot'
        }, function() {
          return svg({
            style: 'height: 500px; width: 500px;'
          });
        });
        span('X Axis: ', function() {
          return select({
            id: 'x-axis'
          }, function() {
            option(function() {
              return '1';
            });
            option(function() {
              return '2';
            });
            option(function() {
              return '3';
            });
            option(function() {
              return '4';
            });
            return option(function() {
              return '5';
            });
          });
        });
        span('Y Axis: ', function() {
          return select({
            id: 'y-axis'
          }, function() {
            option(function() {
              return '1';
            });
            option(function() {
              return '2';
            });
            option(function() {
              return '3';
            });
            option(function() {
              return '4';
            });
            return option(function() {
              return '5';
            });
          });
        });
        a('.btn.expand', function() {
          return 'Expand Scale';
        });
        a('.btn.contract', function() {
          return 'Contract Scale';
        });
        div({
          id: 'distribution-plot'
        });
        return table(function() {
          tr(function() {
            return th(function() {
              return 'Skull Length';
            });
          });
          tr(function() {
            return th(function() {
              return 'Cranial Width';
            });
          });
          tr(function() {
            return th(function() {
              return 'Neurocranial Height';
            });
          });
          tr(function() {
            return th(function() {
              return 'Facial Height';
            });
          });
          tr(function() {
            return th(function() {
              return 'Palate Length';
            });
          });
          tr(function() {
            return th(function() {
              return 'Palate Width';
            });
          });
          return tr(function() {
            th(function() {});
            th(function() {
              return 'Skull Length';
            });
            th(function() {
              return 'Cranial Width';
            });
            th(function() {
              return 'Neurocranial Height';
            });
            th(function() {
              return 'Facial Height';
            });
            th(function() {
              return 'Palate Length';
            });
            return th(function() {
              return 'Palate Width';
            });
          });
        });
      }
    });
    this.coffee({
      '/n3plots.js': function() {
        return $(function() {
          var randomData;
          nv.addGraph(function() {
            var chart;
            chart = nv.models.scatterChart().color(d3.scale.category10().range()).showControls(false).showLegend(false).showDistX(false).showDistY(false);
            chart.xAxis.tickFormat(d3.format('.02f'));
            chart.yAxis.tickFormat(d3.format('.02f'));
            d3.select('#scatterplot svg').datum(randomData(4, 40)).transition().duration(500).call(chart);
            nv.utils.windowResize(chart.update);
            return chart;
          });
          return randomData = function(groups, points) {
            var random, shapes;
            shapes = ['circle', 'square', 'diamond', 'cross', 'triangle-up', 'triangle-down'];
            random = d3.random.normal();
            return _.map(_.range(groups), function(idx) {
              return {
                key: "Group " + idx,
                values: _.map(_.range(points), function() {
                  return {
                    x: random(),
                    y: random(),
                    size: 10,
                    shape: shapes[idx % 6]
                  };
                })
              };
            });
          };
        });
      }
    });
    this.coffee({
      '/multiscatter.js': function() {
        return $(function() {
          var chart, vars, x, y;
          vars = [
            {
              key: 'skull_length',
              label: 'Skull Length'
            }, {
              key: 'cranial_width',
              label: 'Cranial Width'
            }, {
              key: 'neurocranial_height',
              label: 'Neurocranial Height'
            }, {
              key: 'facial_height',
              label: 'Facial Height'
            }, {
              key: 'palate_length',
              label: 'Palate Length'
            }, {
              key: 'palate_width',
              label: 'Palate Width'
            }
          ];
          x = d3.scale.ordinal();
          x.domain(_.pluck(vars, 'label'));
          y = d3.scale.ordinal();
          x.domain(_.pluck(vars, 'label'));
          return chart = d3.select('#multiscatter svg');
        });
      }
    });
    return this.coffee({
      '/plots.js': function() {
        return $(function() {
          var data, distributionPlot, scatterplot;
          data = _.map(d3.range(500), function() {
            return _.map(d3.range(5), Math.random);
          });
          scatterplot = function() {
            var chart, dataPoints, distance, gridLines, h, hLines, highlightPt, points, svg, testHalo, testPoint, updateScale, updateVars, vLines, voronoiGroup, w, x, xAxis, xAxisG, xVar, y, yAxis, yAxisG, yVar;
            w = 500;
            h = 500;
            svg = d3.select('#scatterplot').append('svg:svg').attr('width', w).attr('height', h);
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
            voronoiGroup = svg.append('svg:g').attr('class', 'voronoi-polygons');
            dataPoints = svg.append('svg:g').attr('class', 'data-points');
            points = dataPoints.selectAll('circle').data(data);
            xVar = 0;
            yVar = 1;
            $('select#x-axis').change(function(e) {
              xVar = parseInt($(e.currentTarget).val()) - 1;
              return updateVars();
            });
            $('select#y-axis').change(function(e) {
              yVar = parseInt($(e.currentTarget).val()) - 1;
              return updateVars();
            });
            points.enter().append('svg:circle').attr('cx', function(d) {
              return x(d[xVar]);
            }).attr('cy', function(d) {
              return y(d[yVar]);
            }).attr('r', 3).style('stroke', 'black').style('fill', 'red').on('mouseover', function(d) {
              return d3.select(this).transition().style('fill', 'blue').attr('r', 10).style('stroke-width', 4);
            }).on('mouseout', function(d) {
              return d3.select(this).transition().style('fill', 'red').attr('r', 3).style('stroke-width', 1);
            });
            points.exit().remove();
            updateVars = function() {
              var voronoiData, voronoiShapes;
              updateScale();
              voronoiGroup.selectAll('polygon').remove();
              voronoiData = d3.geom.voronoi(_.map(data, function(d) {
                return [x(d[xVar]), y(d[yVar])];
              }));
              voronoiShapes = voronoiGroup.selectAll('polygon').data(voronoiData);
              return voronoiShapes.enter().append('svg:polygon').attr('points', function(d) {
                return _.map(d, function(p) {
                  return "" + p[0] + "," + p[1];
                }).join(' ');
              }).on('mouseover', function() {
                return d3.select(this).style('fill', 'green');
              }).on('mouseout', function() {
                return d3.select(this).style('fill', 'none');
              }).on('mousemove', function(d) {
                return console.log('mousemove');
              });
            };
            distance = function(_arg, _arg2) {
              var x1, x2, xdiff, y1, y2, ydiff;
              x1 = _arg[0], y1 = _arg[1];
              x2 = _arg2[0], y2 = _arg2[1];
              xdiff = x2 - x1;
              ydiff = y2 - y1;
              return Math.sqrt(xdiff * xdiff + ydiff * ydiff);
            };
            highlightPt = svg.append('svg:g').attr('class', 'highlight-point').attr('transform', 'translate(250, 250) scale(2)');
            testPoint = highlightPt.append('svg:circle').attr('r', 10).style('fill', 'blue');
            testHalo = highlightPt.append('svg:circle').attr('r', 20).style('fill', 'none').style('stroke-width', 1).style('stroke', 'black');
            updateScale = function() {
              xAxisG.transition().call(xAxis);
              yAxisG.transition().call(yAxis);
              return points.transition().attr('cx', function(d) {
                return x(d[xVar]);
              }).attr('cy', function(d) {
                return y(d[yVar]);
              });
            };
            $('.expand').click(function() {
              x.domain([x.domain()[0] * 1.1, x.domain()[1] * 1.1]);
              y.domain([y.domain()[0] * 1.1, y.domain()[1] * 1.1]);
              return updateScale();
            });
            $('.contract').click(function() {
              x.domain([x.domain()[0] * 0.9, x.domain()[1] * 0.9]);
              y.domain([y.domain()[0] * 0.9, y.domain()[1] * 0.9]);
              return updateScale();
            });
            return updateVars();
          };
          distributionPlot = function() {
            var barWidth, bars, bucketSize, buckets, chart, dataBars, gridLines, h, hLines, numBuckets, scale, svg, updateScale, vLines, varkey, w, x, xAxis, xAxisG, y, yAxis, yAxisG;
            varkey = 0;
            numBuckets = 20;
            buckets = [];
            scale = d3.scale.linear();
            scale.domain([0, 1]).range([0, 1]);
            bucketSize = scale(1.0 / numBuckets);
            _.each(d3.range(numBuckets), function(idx) {
              return buckets[idx] = 0;
            });
            _.each(data, function(d) {
              var idx;
              idx = Math.floor(scale(d[varkey]) / bucketSize);
              return buckets[idx] += 1;
            });
            w = 500;
            h = 500;
            svg = d3.select('#distribution-plot').append('svg:svg').attr('width', w).attr('height', h);
            chart = svg.append('rect').attr('x', 0.1 * svg.attr('width')).attr('y', 0).attr('width', 0.9 * svg.attr('width')).attr('height', 0.9 * svg.attr('height')).style('fill', 'green');
            x = d3.scale.linear();
            y = d3.scale.linear();
            xAxis = d3.svg.axis().scale(x).orient('bottom');
            yAxis = d3.svg.axis().scale(y).orient('left');
            x.domain(d3.extent(data[varkey]));
            x.range([parseInt(chart.attr('x')), parseInt(chart.attr('x')) + parseInt(chart.attr('width'))]);
            y.domain([0, d3.extent(buckets)[1]]);
            y.range([chart.attr('y'), parseInt(chart.attr('y')) + parseInt(chart.attr('height'))]);
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
            barWidth = chart.attr('width') / numBuckets;
            dataBars = svg.append('svg:g').attr('class', 'data-bars').attr('transform', "translate(" + (0.1 * svg.attr('width')) + ", " + (0.9 * svg.attr('height')) + ")");
            bars = dataBars.selectAll('rect').data(buckets);
            bars.enter().append('rect').attr('x', function(d, i) {
              return i * barWidth;
            }).attr('y', 0).attr('width', barWidth).attr('height', function(d) {
              console.log("" + d + " -> " + (y(d)));
              return y(d);
            }).attr('transform', 'scale(1, -1)').style('stroke', 'black').style('fill', 'red');
            bars.exit().remove();
            return updateScale = function() {
              xAxisG.transition().call(xAxis);
              yAxisG.transition().call(yAxis);
              return points.transition().attr('cx', function(d) {
                return x(d[xVar]);
              }).attr('cy', function(d) {
                return y(d[yVar]);
              });
            };
          };
          scatterplot();
          return distributionPlot();
        });
      }
    });
  };

}).call(this);
