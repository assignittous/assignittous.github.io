'use strict'
gulp   = require('gulp')
concat = require('gulp-concat')
plumber = require('gulp-plumber')
coffee = require('gulp-coffee')
logger = require('./lib/logger.coffee')

module.exports = ()->
  logger.info 'ASSET', "Compile core coffeescripts"
  gulp.src("./_js/**/*.coffee").pipe(plumber()).pipe(coffee({bare:true})).pipe(concat("_app.js")).pipe(gulp.dest("./js"))
  return


module.exports.taskName = 'compile-coffee'
module.exports.watch = 'databases/**/*.jade'