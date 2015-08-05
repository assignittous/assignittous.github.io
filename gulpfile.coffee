'use strict'


taskMasterOptions = 
  dirname: '_gulp' 
  pattern: '*.coffee' 
  cwd: process.cwd() 
  watchExt: '.watch'  

gulp = require('gulp-task-master')(taskMasterOptions)



botTasks = ['preview-jade.watch','preview-sass.watch', 'preview-blog.watch']

gulp.task "watch", botTasks
gulp.task "bot", botTasks

# Tasks that are in lib-gulp can be run as

# gulp assets-bower -- not working yet
# gulp compile-blog -- not working yet
# gulp compile-coffee -- not working yet
# gulp compile-jade -- compile _content folder
# gulp compile-sass -- copmile _sass folder
# gulp housekeeping -- deletes content before republishing
gulp.task "preview", ['preview-jade', 'preview-sass', 'preview-blog']

gulp.task "default", ['compile-jade', 'compile-sass', 'compile-blog']


