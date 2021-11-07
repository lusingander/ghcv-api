const gh = require('github-username-regex');

exports.userIdTest = (id) => gh.test(id);