# housekeeping.coffee

###

Delete all compiled files (*.html)

###

del = require('del')
CSON = require('cson')
logger = require('../logger').Logger


module.exports = ()->
  cwd = process.env.PWD || process.cwd()
  console.log "CWD: #{cwd}"
  settings = CSON.parseCSONFile("#{cwd}/config.cson")

  logger.warn 'WARN', "Housekeeping"

  console.log settings.housekeeping
  del.sync settings.housekeeping
  return


module.exports.taskName = 'housekeeping'
