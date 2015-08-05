###

# Compile lib folder

`gulp compile-blog`


---
###

aitutils = require('aitutils').aitutils
file = aitutils.file
logger = aitutils.logger
path = require "path"
_ = require "lodash"
CSON = require "cson"
marked = require('marked')
jade = require('jade')

# paths


# sourcePath = ["./src/**/*.coffee","!./src/cli.coffee", "!./src/gulp/**.*"]
# targetPath = "./"



module.exports = ()->


  findAbstract = (text)->

    bodyDivider = text.indexOf("---body")
    abstractDivider = text.indexOf("---abstract")
    abstractStart = abstractDivider + 11

    if abstractDivider < 0
      return ""
    else
      if (bodyDivider < 0) || (abstractDivider > bodyDivider)
        return text.substring(abstractStart)
      else
        if abstractDivider < bodyDivider
          return text.substring(abstractStart, bodyDivider)
        else # impossible case
          return ""

  findBody = (text)->

    bodyDivider = text.indexOf("---body")
    abstractDivider = text.indexOf("---abstract")
    bodyStart = bodyDivider + 7

    if bodyDivider < 0
      return ""
    else
      if (abstractDivider < 0) || (bodyDivider > abstractDivider)
        return text.substring(bodyStart)
      else
        if bodyDivider < abstractDivider
          return text.substring(bodyStart, abstractDivider)
        else # impossible case
          return ""





  frontMatter = (filePath)->
    text = file.open filePath

    csonEnd = text.indexOf('---')
    if csonEnd < 0
      csonEnd = text.length()


    locals = text.substring(0,csonEnd)
    # 
    body = findBody(text)
    abstract = findAbstract(text)

    # Parse the CSON portion
    obj = CSON.parse locals
    # Add markdown content as attributes
    obj["body"] = marked(body).replace(/\n/g,"")
    obj["abstract"] = marked(abstract).replace(/\n/g,"")

    return obj


  allContent = {}
  archiveIndex = 
    years: []


  housekeeping = ()->
    # clean up the file structure for the blog

  callback = (dirPath, dirs, files)->
    #console.log dirPath
    #console.log dirs
    #console.log files
    
    dirPath = path.normalize(dirPath)
    if dirPath == ".#{path.sep}entries"
      return
    else
      console.log "currentPath"
      currentPath = dirPath.replace("entries#{path.sep}","")
      console.log currentPath
      
      # todo: normalize the path

      pathElements = currentPath.split(path.sep)
      console.log pathElements
      switch pathElements.length

        when 3 # year
          console.log "year is #{currentPath}"
          if (currentPath != "_templates") && (currentPath != "_drafts")

            allContent[pathElements[2]] = {}
            archiveIndex.years.push
              name: currentPath
              months: dirs.sort()

        when 4 # month
          logger.info "132"
          console.log allContent
          year = pathElements[2]
          month = pathElements[3]     
          logger.info "135"       
          allContent[year][month] = []
          logger.info "137"
          # sort the files in this folder



          _.forEach files, (item)->
            content = frontMatter(dirPath + "/" + item)
            content["permalink"] = path.join("/","blog",year,month,item.replace('.txt','.html'))
            logger.info "145"
            if content.publish == true

              allContent[year][month].push content


            else
              console.log "skipped draft #{currentPath}/#{item}"
      return

  file.traverse "./_content/blog", callback






  # Ensure that years are sorted in ascending order
  years = _.keys(allContent).sort()

  #  console.log years.sort()
  _.forEach years, (year)->

    # do Archive

    content = allContent[year]
    months = _.keys(content).sort (a,b)->
      return parseInt(a) - parseInt(b)

    
    _.forEach months, (month)->
      entries = content[month]
      entries = _.sortBy entries, (n)->

        if n.day < 10
          ordinal = "0#{n.day}#{n.time}"
        else
          ordinal = "#{n.day}#{n.time}"
        return ordinal


      # permalinks

      _.forEach entries, (entry)->
        console.log entry.permalink
        # do Permalink

        permalink = jade.compileFile "./_content/blog/_templates/permalink.jade" , { pretty: true }

        file.newFolder path.join("./", path.dirname(entry.permalink))

        file.save path.join("./", entry.permalink), permalink(entry)


      # archive is not paginated

      archive = jade.compileFile "./_content/blog/_templates/archive.jade", {pretty: true}

      archivePath = path.join("./","blog", year, "#{month}.html")

      file.save archivePath, archive(entries: entries)

      


      # resort entries for blog
      entries = _.sortByOrder entries, ["day","time"],["asc","asc"]



    #console.log dirPath
    

  # reverse sort blog entries

  years = _.keys(allContent).sort (a,b)->
      return parseInt(b) - parseInt(a)


  blogContent = {
    pages: []
  }
  currentPage = 
    entries: []
  pageCounter = 0

  #  console.log years.sort()
  _.forEach years, (year)->

    # do Archive
    


    content = allContent[year]

    months = _.keys(content).sort (a,b)->
      return parseInt(b) - parseInt(a)

    
    _.forEach months, (month)->
      entries = content[month]
      entries = _.sortByOrder entries, ["day","time"],["desc","desc"] 


      _.forEach entries, (entry)->
        entry["year"] = year
        entry["month"] = month

        currentPage.entries.push entry
        # console.log currentPage
        pageCounter++
        if pageCounter == 5
          console.log "5"
          pageCounter = 0
          blogContent.pages.push currentPage
          currentPage.entries = []            


      # archive is NOT paginated

      archive = jade.compileFile "./_content/blog/_templates/archive.jade", {pretty: true}

      archivePath = path.join("./","blog", year, "#{month}.html")

      file.save archivePath, archive(entries: entries)

      



      archiveIndexPage = jade.compileFile "./_content/blog/_templates/archive_index.jade", {pretty: true}
      archiveIndexPath = path.join("./","blog", "archive.html")      
      file.save archiveIndexPath, archiveIndexPage(archiveIndex)




  if currentPage.entries.length > 0
    blogContent.pages.push currentPage


  console.log blogContent.pages.length
  # permalinks

  pageNumber = 1
  _.forEach blogContent.pages, (page)->
    
    # indicate the maximum number of pages to do paging
    
    page["current_page"] = pageNumber
    page["total_pages"] = blogContent.pages.length

    blogPage = jade.compileFile "./_content/blog/_templates/blog.jade" , { pretty: true }

    if pageNumber == 1
      outputName = "index.html"
    else
      outputName = "page_#{pageNumber}.html"

    file.save path.join("./blog", outputName), blogPage(page)
    pageNumber++










     
    





# module.exports.watch = sourcePath