'use strict'
gulp   = require('gulp')
concat = require('gulp-concat')
plumber = require('gulp-plumber')
coffee = require('gulp-coffee')
aitutils = require('aitutils').aitutils
file = aitutils.file
logger = aitutils.logger
module.exports = ()->
  logger.info 'ASSET', "Compile core coffeescripts"
  gulp.src("./_js/**/*.coffee").pipe(plumber()).pipe(coffee({bare:true})).pipe(concat("_app.js")).pipe(gulp.dest("./js"))
  return


module.exports.taskName = 'compile-coffee'
module.exports.watch = 'databases/**/*.jade'