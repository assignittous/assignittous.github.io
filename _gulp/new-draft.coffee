###

# Compile lib folder

`gulp compile-blog`


---
###

aitutils = require('aitutils').aitutils
file = aitutils.file
logger = aitutils.logger
general = aitutils.general
path = require "path"
_ = require "lodash"
CSON = require "cson"
marked = require('marked')
jade = require('jade')

# paths


# sourcePath = ["./src/**/*.coffee","!./src/cli.coffee", "!./src/gulp/**.*"]
# targetPath = "./"



module.exports = ()->

  stamp = general.dateSid()
  day = general.dateSid('d')
  draftPath = "./_content/blog/_drafts/"

  template = """
title: "#{stamp}"
author: ""
publish: true
day: #{day}
time: "17:30"
---abstract
Markdown content goes here
---body
Markdown content goes here
  """
  #console.log template
  file.save "#{draftPath}draft-#{stamp}.txt", template