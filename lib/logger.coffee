'use strict'

chalk = require('chalk')
require 'sugar'

exports.Logger = 
  output: (type, msg)->
    console.log "[#{Date.create().format('{HH}:{mm}:{ss}')}] #{type} #{msg}"
  info: (msg)->
    @output chalk.bgWhite.black(" INFO "), msg
  error: (msg)->
    @output chalk.bgRed.black(" ERROR "), msg
  warn: (msg)->
    @output chalk.bgYellow.black(" WARN "), msg
  bot: (msg)->
    @output chalk.bgGreen.white(" BOT "), msg
  shell: (msg)->
    @output chalk.bgBlue.white(" SHELL: "), ""
    console.log msg