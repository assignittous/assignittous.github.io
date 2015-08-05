# housekeeping.coffee

###

Delete all compiled files (*.html)

###

del = require('del')
CSON = require('cson')
aitutils = require('aitutils').aitutils
file = aitutils.file
logger = aitutils.logger


module.exports = ()->
  cwd = process.env.PWD || process.cwd()
  settings = CSON.parseCSONFile("#{cwd}/config.cson")
  logger.warn "Housekeeping"
  console.log settings.housekeeping
  del.sync settings.housekeeping
  return


module.exports.taskName = 'housekeeping'
