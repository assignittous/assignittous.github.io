'use strict'
gulp   = require('gulp')
plumber = require('gulp-plumber')
bowerfiles = require('main-bower-files')
aitutils = require('aitutils').aitutils
file = aitutils.file
logger = aitutils.logger

module.exports = ()->
  logger.info 'ASSET', "Compile core coffeescripts"
  gulp.src(bowerfiles()).pipe gulp.dest "./assets/bower"
  return


module.exports.taskName = 'assets-bower'
# module.exports.watch = 'databases/**/*.jade'