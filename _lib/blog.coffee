
aitutils = require('aitutils').aitutils
general = aitutils.general
file = aitutils.file
logger = aitutils.logger
path = require "path"
_ = require "lodash"
CSON = require "cson"
marked = require('marked')
jade = require('jade')
# blog = require("../_lib/blog").Blog
require "sugar"
# paths


exports.Blog =

  monthNames: ["January","February","March","April","May","June","July","August","September","October","November","December"]
  outputPath: ""
  startPath: "./_content/blog"

  findElement: (mainTag, otherTag, text)->
    firstDivider = text.indexOf(mainTag)
    secondDivider = text.indexOf(otherTag)
    firstStart = secondDivider + otherTag.length

    if secondDivider < 0
      return ""
    else
      if (firstDivider < 0) || (secondDivider > firstDivider)
        return text.substring(firstStart)
      else
        if secondDivider < firstDivider
          return text.substring(firstStart, firstDivider)
        else # impossible case
          return ""




  frontMatter: (filePath)->
    text = file.open filePath

    csonEnd = text.indexOf('---')
    if csonEnd < 0
      csonEnd = text.length()


    locals = text.substring(0,csonEnd)
    # 
    body = @findElement("---body","---abstract",text)
    abstract = @findElement("---abstract","---body",text)

    # Parse the CSON portion
    obj = CSON.parse locals
    # Add markdown content as attributes
    obj["body"] = marked(body).replace(/\n/g,"")
    obj["abstract"] = marked(abstract).replace(/\n/g,"")

    return obj


  allContent: {}
  archiveIndex: 
    years: []

  
  housekeeping: ()->
    # clean up the file structure for the blog
  aggregate: ()->

    that = @

    file.traverse @startPath, (dirPath, dirs, files)->

      
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
                  name: that.monthNames[parseInt(o)-1]
                }
              that.allContent[pathElements[2]] = {}
              that.archiveIndex.years.push
                name: currentPath
                months: months

          when 4 # month
            year = pathElements[2]
            month = pathElements[3]     
            that.allContent[year][month] = []
            # sort the files in this folder



            files.each (item)->
              content = that.frontMatter(dirPath + "/" + item)
              content["year"] = year
              content["month"] = month
              content["post_at"] = Date.create("#{year}-#{month}-#{content.day} #{content.time}").full()
              content["permalink"] = path.join("/","blog",year,month,item.replace('.txt','.html')).replace(/\\/g,"/")

              if content.publish == true

                that.allContent[year][month].push content


              else
                logger.info "skipped draft #{currentPath}/#{item}"
        return


  permalinks: ()->
    # Ensure that years are sorted in ascending order
    
    that = @
    years = Object.keys(@allContent).sort()

    years.each (year)->

      # do Archive

      content = that.allContent[year]
      months = Object.keys(content).sort (a,b)->
        return parseInt(a) - parseInt(b)

      
      months.each (month)->
        entries = content[month]
        entries = _.sortBy entries, (n)->

          if n.day < 10
            ordinal = "0#{n.day}#{n.time}"
          else
            ordinal = "#{n.day}#{n.time}"
          return ordinal


        # permalinks

        entries.each (entry)->
          
          # do Permalink

          permalink = jade.compileFile "#{that.startPath}/_templates/permalink.jade" , { pretty: true }

          file.newFolder path.join(that.outputPath, path.dirname(entry.permalink))

          file.save path.join(that.outputPath, entry.permalink), permalink(entry)
          logger.info "Saved permalink: #{path.join(that.outputPath, entry.permalink)}"

  blog: ()->

  archive: ()->
    that = @

    entries = _.sortByOrder entries, ["day","time"],["asc","asc"]


    # reverse sort blog entries

    years = Object.keys(@allContent).sort (a,b)->
        return parseInt(b) - parseInt(a)

    years.each (year)->

      # do Archive
      


      content = that.allContent[year]

      months = Object.keys(content).sort (a,b)->
        return parseInt(b) - parseInt(a)

      
      months.each (month)->
        entries = content[month]
        entries = _.sortByOrder entries, ["day","time"],["desc","desc"] 



        # archive is NOT paginated

        archive = jade.compileFile "#{that.startPath}/_templates/archive.jade", {pretty: true}

        archivePath = path.join(that.outputPath,"blog", year, "#{month}.html")
        monthName = that.monthNames[parseInt(month)-1]
        file.save archivePath, archive(
          {
            entries: entries
            year: year
            month: month
            monthName: monthName
          }
        )
        logger.info "Saved archive for #{monthName}/#{year}: #{path.join(that.outputPath,"blog", year, "#{month}.html")}"

    # write archive index pages

    archiveIndexPage = jade.compileFile "#{that.startPath}/_templates/archive_index.jade", {pretty: true}
    archiveIndexPath = path.join(that.outputPath,"blog", "archive.html")      
    file.save archiveIndexPath, archiveIndexPage(@archiveIndex)
    logger.info "Saved archive index: #{archiveIndexPath}"

  generate: ()->

    that = @


        # resort entries for blog
    entries = _.sortByOrder entries, ["day","time"],["asc","asc"]



    # reverse sort blog entries

    years = Object.keys(that.allContent).sort (a,b)->
        return parseInt(b) - parseInt(a)


    blogContent = {
      pages: []
    }
    currentPage = 
      entries: []
    pageEntryCounter = 0


    years.each (year)->

      # do Archive
      


      content = that.allContent[year]

      months = Object.keys(content).sort (a,b)->
        return parseInt(b) - parseInt(a)

      
      months.each (month)->
        entries = content[month]
        entries = _.sortByOrder entries, ["day","time"],["desc","desc"] 


        entries.each (entry)->
          entry["year"] = year
          entry["month"] = month

          currentPage.entries.push entry

          pageEntryCounter++
          if pageEntryCounter == 5
            pageEntryCounter = 0
            blogContent.pages.push Object.clone(currentPage, true)
            logger.info "Generated blog page #{blogContent.pages.length}" 
            currentPage.entries = []            


    if currentPage.entries.length > 0
      blogContent.pages.push currentPage
      logger.info "Generated blog page #{blogContent.pages.length}"    

    # permalinks

    pageNumber = 1
    blogContent.pages.each (page)->
      
      # indicate the maximum number of pages to do paging
      
      page["current_page"] = pageNumber
      page["total_pages"] = blogContent.pages.length

      blogPage = jade.compileFile "#{that.startPath}/_templates/blog.jade" , { pretty: true }

      if pageNumber == 1
        outputName = "index.html"
      else
        outputName = "page_#{pageNumber}.html"

      file.save path.join(that.outputPath, "blog", outputName), blogPage(page)
      logger.info "Saved blog page #{page}: #{path.join(that.outputPath, "blog", outputName)}"
      pageNumber++

  processTo: (outputPath)->
    @outputPath = outputPath
    @aggregate()
    @permalinks()
    @archive()
    @generate()    