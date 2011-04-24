task 'start', 'Start the Fit Predictor API and monitor with Supervisor', ->
  sv = require "supervisor"
  sv.run "-e coffee -x coffee server.coffee".split(" ")
