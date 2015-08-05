'use strict'
gulp   = require('gulp')
concat = require('gulp-concat')
plumber = require('gulp-plumber')
jade = require('gulp-jade')
aitutils = require('aitutils').aitutils
file = aitutils.file
logger = aitutils.logger

module.exports = ()->
  logger.info 'ASSET', "Compile core jadescripts"

  sourcePaths = ["./_content/**/*.jade", "!./_content/**/_*.jade", "!./_content/blog/_templates/*.jade"]

  gulp.src(sourcePaths).pipe(plumber()).pipe(jade({ locals: {} })).pipe(gulp.dest("./_preview/"))
  return



module.exports.watch = './_content/**/*.jade'