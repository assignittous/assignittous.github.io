'use strict'
gulp   = require('gulp')
concat = require('gulp-concat')
plumber = require('gulp-plumber')
jade = require('gulp-jade')
logger = require('./lib/logger.jade')

module.exports = ()->
  logger.info 'ASSET', "Compile core jadescripts"
  gulp.src("./_js/**/*.jade").pipe(plumber()).pipe(jade({bare:true})).pipe(concat("_app.js")).pipe(gulp.dest("./js"))
  return


module.exports.taskName = 'compile-jade-site'
module.exports.watch = 'databases/**/*.jade'