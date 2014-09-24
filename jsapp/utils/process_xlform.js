#!/usr/bin/env node

var require = require('requirejs'),
    program = require('commander'),
    path = require('path'),
    components,
    xlform;

require.config({
  baseUrl: path.resolve(__dirname, '..')
});

// load the paths from the common paths file (test/components)
components = require('test/components');
require.define('cs!xlform/mv.skipLogicHelpers', [], function(){return {}});
require.define('cs!xlform/model.rowDetailMixins', [], function(){return {}});

require.config({
  paths: (function(){
    var _k, _p = {};
    for (_k in components.libs)       { _p[_k] = components.libs[_k].replace(/\.js$/, '') }
    for (_k in components.nodeStubs)  { _p[_k] = components.nodeStubs[_k]; }
    for (_k in components.dirPaths)   { _p[_k] = components.dirPaths[_k]; }
    return _p;
  })()
});
xlform = require('cs!xlform/_xlform.init');

program
  .version('0.0.1')
  .option('-a, --action [action]', 'action to be performed (eg. summarize, shrink)')
  .option('-f, --file [path]', 'open file path')
  .option('-o, --output [path]', 'specify output file path (default streams to stdout)')
  .option('-t, --type [type]', 'specify the type of the input [survey]', 'survey')
  .parse(process.argv);


function with_stdin(csv_repr, opts) {
  var stype = opts.type || 'survey';

  var _xlf = xlform.model.Survey.load(csv_repr);

  if (program.action === 'shrink') {
    process.stdout.write(_xlf.toCSV());
  } else if (program.action === 'summarize') {
    process.stdout.write(JSON.stringify(_xlf.summarize()));
  } else {
    throw new Error('Action not recognized');
  }
}

if (program.file) {
  console.log(program.file);
} else {
  (function(){
    var chunks = [];
    process.stdin.setEncoding('utf8');

    process.stdin.on('readable', function(chunk) {
      var chunk = process.stdin.read();
      if (chunk !== null) chunks.push(chunk);
    });

    process.stdin.on('end', function() {
      with_stdin(chunks.join(''), {
        type: program.type
      });
    });
  })();
}
