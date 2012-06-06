_ = require('underscore')._
Backbone = require('backbone')

# Simple model to publishing of and subscription to alert messages
class Alerts extends Backbone.Model
  Types: {SUCCESS: 'success', INFO: 'info', WARNING: 'warning', ERROR: 'error'}
  publish: (type=Alerts.Types.INFO, body) ->
    @trigger('published', {type: type, body: body})

_.extend exports,
  'Alerts': Alerts
