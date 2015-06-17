'use strict'
gulp   = require('gulp')
concat = require('gulp-concat')
plumber = require('gulp-plumber')
jade = require('gulp-jade')
logger = require('../logger').Logger

module.exports = ()->
  logger.info 'ASSET', "Compile core jadescripts"

  sourcePaths = ["./_content/**/*.jade", "!./_content/**/_*.jade"]

  gulp.src(sourcePaths).pipe(plumber()).pipe(jade({ locals: {} })).pipe(gulp.dest("./"))
  return


module.exports.taskName = 'compile-jade'
module.exports.watch = './_content/**/*.jade'