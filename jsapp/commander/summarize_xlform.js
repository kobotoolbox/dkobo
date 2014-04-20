#!/usr/bin/env node

/**
 * Module dependencies.
 */

var require = require('requirejs'),
    program = require('commander'),
    xlform;

// needs configuration
require.config({});

require('xlform/xlform_model_amd')
xlform = require('cs!models/model');

program
  .version('0.0.1')
  .option('-s, --shrink', 'shrink to more concise xlform')
  .option('-S, --summarize', 'summarize xlform')
  .option('-f, --file [path]', 'open file path')
  .option('-o, --output [path]', 'specify output file path (default streams to stdout)')
  .option('-t, --type [type]', 'specify the type of the input [survey]', 'survey')
  .parse(process.argv);

function with_xlform(csv_repr, opts) {
  var survey = new xlform.Survey.Survey.load(csv_repr)
  var stype = opts.type || 'survey';
  var outStr = JSON.stringify(survey.rows.at(0).getList().options.models[0]);
  process.stdout.write(''+outStr);
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
      with_xlform(chunks.join(''), {
        type: program.type
      });
    });
  })();
}
