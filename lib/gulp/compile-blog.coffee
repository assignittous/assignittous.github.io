'use strict'
gulp   = require('gulp')
concat = require('gulp-concat')
plumber = require('gulp-plumber')
jade = require('gulp-jade')
logger = require('../logger').Logger
fs = require('fs-extra')

module.exports = ()->
  logger.info 'ASSET', "Compile core jadescripts"


  # logic

  ###
    scan blog folder, which is organized by:

    yyyy
      - mm
        post.cson


    reverse sort the year folders
      reverse sort the month folders

    output
      yyyy
        mm
          dd-hhmm.html < permalink


      archive
        index.html <- links to archive pages 
        yyyy
          mm.html < link + abstract

      index.html <- current, archive link at bottom

  ###



  #sourcePaths = ["./_content/**/*.jade", "!./_content/**/_*.jade", "!./_content/blog"]

  #gulp.src(sourcePaths).pipe(plumber()).pipe(jade({ locals: {} })).pipe(gulp.dest("./"))
  return


module.exports.taskName = 'compile-jade'
module.exports.watch = './_content/**/*.jade'