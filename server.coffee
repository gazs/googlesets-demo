express = require 'express'
googlesets = require 'googlesets'

public = "#{__dirname}/public"

app = express.createServer(
  express.compiler({src: public, enable: ['coffeescript']}),
  express.static public
)

app.get '/sets/:size/:words', (req, res) ->
  try
    googlesets[req.params.size] JSON.parse(req.params.words), (results) ->
      res.send results
  catch e
    res.send e

app.listen 3000
