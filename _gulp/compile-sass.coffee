'use strict'
gulp   = require('gulp')
plumber = require('gulp-plumber')
sass = require('gulp-sass')
aitutils = require('aitutils').aitutils
file = aitutils.file
logger = aitutils.logger

module.exports = ()->
  logger.info 'ASSET', "Compile core coffeescripts"
  gulp.src(["./_sass/**/*.sass","!./_sass/**/_*.sass"]).pipe(plumber()).pipe(sass({indentedSyntax: true})).pipe(gulp.dest("./css"))
  return


module.exports.taskName = 'compile-sass'
module.exports.watch = 'databases/**/*.jade'