#!/usr/bin/env node

var require = require('requirejs'),
    program = require('commander'),
    path = require('path'),
    xlform;

require.config({
  baseUrl: path.resolve(__dirname, '..'),
  paths: {
    'jquery': 'components/jquery/dist/jquery',
    'cs' :'components/require-cs/cs',
    'backbone': 'components/backbone/backbone',
    'underscore': 'components/underscore/underscore',
    'coffee-script': 'components/require-cs/coffee-script',
  }
});

xlform = require('cs!xlform_model_view/model');

program
  .version('0.0.1')
  .option('-s, --shrink', 'shrink to more concise xlform')
  .option('-S, --summarize', 'summarize xlform')
  .option('-f, --file [path]', 'open file path')
  .option('-o, --output [path]', 'specify output file path (default streams to stdout)')
  .option('-t, --type [type]', 'specify the type of the input [survey]', 'survey')
  .parse(process.argv);

function with_xlform(csv_repr, opts) {
  var stype = opts.type || 'survey';
  var outStr = xlform.reverse(csv_repr);
  // var survey = new xlform.Survey.load(csv_repr)
  // var outStr = JSON.stringify(survey.rows.at(0).getList().options.models[0]);
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
