express = require 'express'
googlesets = require 'googlesets'

public = "#{__dirname}/public"

app = express.createServer(
  express.compiler({src: public, enable: ['coffeescript']}),
  express.static public
  express.logger()
)

app.get '/sets/:size/:words', (req, res, next) ->
    googlesets[req.params.size] JSON.parse(req.params.words), (err, results) ->
      console.log err
      if err
        next new Error # ha csak throwolok errort, akkor nincs ki elkapja. nem egyértelmű, hogy én hibázok.
      else
        res.send results

app.error (err, req, res, next) ->
  res.send {gebasz:"jaj"}, 404

app.listen 3000
