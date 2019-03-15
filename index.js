var spawn = require('child_process').spawnSync;

function getRuby() {
    if (process.env.LAMBDA_TASK_ROOT) {
        return './ruby/bin/ruby';
    }

    return 'ruby';
}

exports.handler = function(event, context, callback) {
  var addedEnvironment = {
    GEM_PATH: __dirname
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

  console.log('spawnedProcess: ', spawnedProcess.stdout.toString())

  if (spawnedProcess.stdout.toString().includes('retryable')) {
    callback(new Error("retryable exception"));
  }

  spawnedProcess.stdout.toString().split("\n").map(function (message) {
    if (message.trim().length) console.log(message);
  });

  spawnedProcess.stderr.toString().split("\n").map(function (message) {
    if (message.trim().length) console.log(message);
  });
};
