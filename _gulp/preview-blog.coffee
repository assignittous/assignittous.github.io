###

# Compile lib folder

`gulp preview-blog`


---
###

blog = require("../_lib/blog").Blog

sourcePath = ["./_content/blog/**/*.txt","./_content/blog/_templates/*.jade", "!./_content/blog/_drafts/*.txt"]
outputPath = "./_preview/"

module.exports = ()->

  
  blog.processTo outputPath



module.exports.watch = sourcePath