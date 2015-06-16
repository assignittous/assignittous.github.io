'use strict'


taskMasterOptions = 
  dirname: 'src/gulp' 
  pattern: '*.coffee' 
  cwd: process.cwd() 
  watchExt: '.watch'  

gulp = require('gulp-task-master')(taskMasterOptions)


# gulp.task "watch",  ['compile-lib.watch','compile-bin.watch']

gulp.task "default", []


