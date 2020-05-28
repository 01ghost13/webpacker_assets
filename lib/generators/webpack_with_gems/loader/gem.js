const { execSync } = require('child_process');

const resolvedGemsString = execSync('bundle exec gem_resolver').toString();

// parse("'{}'") => '{}', parse('{}') => {}
const resolvedGems = JSON.parse(JSON.parse(resolvedGemsString));

module.exports = {
  resolvedGems
};
