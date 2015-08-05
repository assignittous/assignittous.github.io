###

# Compile lib folder

`gulp compile-blog`


---
###

aitutils = require('aitutils').aitutils
general = aitutils.general
file = aitutils.file
logger = aitutils.logger
path = require "path"
_ = require "lodash"
CSON = require "cson"
marked = require('marked')
jade = require('jade')
require "sugar"
# paths


sourcePath = ["./_content/blog/**/*.txt","./_content/blog/_templates/*.jade", "!./_content/blog/_drafts/*.txt"]


module.exports = ()->
  monthNames = ["January","February","March","April","May","June","July","August","September","October","November","December"]

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

    
    dirPath = path.normalize(dirPath)
    if dirPath == ".#{path.sep}entries"
      return
    else
      currentPath = dirPath.replace("_content#{path.sep}blog#{path.sep}","")
      
      # todo: normalize the path

      pathElements = dirPath.split(path.sep)
      switch pathElements.length

        when 3 # year
          if !["_templates","_drafts"].any(currentPath)
            months = dirs.sort()
            
            months = months.map (o)->
              return {
                number: o
                name: monthNames[parseInt(o)-1]
              }
            allContent[pathElements[2]] = {}
            archiveIndex.years.push
              name: currentPath
              months: months

        when 4 # month
          year = pathElements[2]
          month = pathElements[3]     
          allContent[year][month] = []
          # sort the files in this folder



          _.forEach files, (item)->
            content = frontMatter(dirPath + "/" + item)
            content["year"] = year
            content["month"] = month
            content["post_at"] = Date.create("#{year}-#{month}-#{content.day} #{content.time}").full()
            content["permalink"] = path.join("/","blog",year,month,item.replace('.txt','.html')).replace("\\","/")

            if content.publish == true

              allContent[year][month].push content


            else
              logger.info "skipped draft #{currentPath}/#{item}"
      return

  file.traverse "./_content/blog", callback






  # Ensure that years are sorted in ascending order
  years = _.keys(allContent).sort()

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
        
        # do Permalink

        permalink = jade.compileFile "./_content/blog/_templates/permalink.jade" , { pretty: true }

        file.newFolder path.join("./_preview/", path.dirname(entry.permalink))

        file.save path.join("./_preview/", entry.permalink), permalink(entry)
        logger.info "Saved permalink #{entry.permalink}"


      # resort entries for blog
      entries = _.sortByOrder entries, ["day","time"],["asc","asc"]



  # reverse sort blog entries

  years = _.keys(allContent).sort (a,b)->
      return parseInt(b) - parseInt(a)


  blogContent = {
    pages: []
  }
  currentPage = 
    entries: []
  pageEntryCounter = 0


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

        pageEntryCounter++
        if pageEntryCounter == 5
          
          pageEntryCounter = 0
          blogContent.pages.push Object.clone(currentPage, true)
          currentPage.entries = []            


      # archive is NOT paginated

      archive = jade.compileFile "./_content/blog/_templates/archive.jade", {pretty: true}

      archivePath = path.join("./_preview/","blog", year, "#{month}.html")
      monthName = monthNames[parseInt(month)-1]
      file.save archivePath, archive(
        {
          entries: entries
          year: year
          month: month
          monthName: monthName
        }
      )
      logger.info "Saved archive for #{monthName} #{year}: #{archivePath}"

      

  archiveIndexPage = jade.compileFile "./_content/blog/_templates/archive_index.jade", {pretty: true}
  archiveIndexPath = path.join("./_preview/","blog", "archive.html")      
  file.save archiveIndexPath, archiveIndexPage(archiveIndex)
  logger.info "Saved archive index "




  if currentPage.entries.length > 0
    blogContent.pages.push currentPage
    logger.info "Generated blog page #{blogContent.pages.length}"    

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

    file.save path.join("./_preview/blog", outputName), blogPage(page)
    pageNumber++









module.exports.watch = sourcePath