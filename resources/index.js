process.env['PATH'] = process.env['PATH'] + ':' + process.env['LAMBDA_TASK_ROOT']

var spawn = require('child_process').spawnSync;

function getRuby() {
    if (process.env.LAMBDA_TASK_ROOT) {
      return './rhrc' ;
    }

    return './rhrc' ;
}

exports.handler = function(event, context) {
  var addedEnvironment = {
    GEM_PATH: __dirname,
    LD_LIBRARY_PATH: __dirname + '/lib'
  };

  var options = {
    input: JSON.stringify(event),
    env: Object.assign(
      process.env,
      addedEnvironment
    )
  };

  var spawnedProcess = spawn(
    getRuby(),
    ['-rbundler/setup', 'main.rb'],
    options
  );

  if (spawnedProcess.error) {
    const message = 'Lambda was unable to execute Ruby (' + spawnedProcess.error + ')';
    return false;
  }

  spawnedProcess.stdout.toString().split("\n").map(function (message) {
    if (message.trim().length) console.log(message);
  });

  spawnedProcess.stderr.toString().split("\n").map(function (message) {
    if (message.trim().length) console.log(message);
  });
};
