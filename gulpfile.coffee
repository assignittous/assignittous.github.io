'use strict'


taskMasterOptions = 
  dirname: 'lib/gulp' 
  pattern: '*.coffee' 
  cwd: process.cwd() 
  watchExt: '.watch'  

gulp = require('gulp-task-master')(taskMasterOptions)



botTasks = ['compile-jade.watch','compile-sass.watch']

gulp.task "watch", botTasks
gulp.task "bot", botTasks

# Tasks that are in lib-gulp can be run as

# gulp assets-bower -- not working yet
# gulp compile-blog -- not working yet
# gulp compile-coffee -- not working yet
# gulp compile-jade -- compile _content folder
# gulp compile-sass -- copmile _sass folder
# gulp housekeeping -- deletes content before republishing


gulp.task "default", ['compile-jade', 'compile-sass']


