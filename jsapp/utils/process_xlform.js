#!/usr/bin/env node

var require = require('requirejs'),
    program = require('commander'),
    path = require('path'),
    components,
    xlform,
    xlform_utils;

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
xlformUtils = require('cs!xlform/_utils');

program
  .version('0.0.1')
  .option('-a, --action [action]', 'action to be performed (eg. summarize, shrink)')
  .option('-p, --params [parameters in json]', 'a json string of parameters to be passed with the action')
  .option('-f, --file [path]', 'open file path')
  .option('-o, --output [path]', 'specify output file path (default streams to stdout)')
  .option('-t, --type [type]', 'specify the type of the input [survey]', 'survey')
  .parse(process.argv);


function with_stdin(csv_repr) {
  var params;

  if (program.params) {
    try {
      params = JSON.parse(program.params.replace(/^'/, '').replace(/'$/, ''));
    } catch(e) {
      params = {parseError: e.message}
    }
  }

  var _xlf = xlform.model.Survey.load(csv_repr);

  if (program.action in xlformUtils) {
    process.stdout.write(JSON.stringify(xlformUtils[program.action](_xlf, params)))
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
      with_stdin(chunks.join(''));
    });
  })();
}
