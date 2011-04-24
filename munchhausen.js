var fs = require('fs');
var coffee = require('coffee-script');

var server = fs.readFile('server.coffee', 'utf-8', function(err, data) {
  if (err) throw err;
  eval(coffee.compile(data))
})
