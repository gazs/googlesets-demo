// A Nodester, ahova deployoltuk a kódot, minden áron egy .js fájlt akar elindítani szervernek.
// Az eval miatt van bűntudatom bőven, persze, de a célnak megfelel és annyira talán nem is otromba.

var fs = require('fs');
var coffee = require('coffee-script');

var server = fs.readFile('server.coffee', 'utf-8', function(err, data) {
  if (err) throw err;
  eval(coffee.compile(data))
})
