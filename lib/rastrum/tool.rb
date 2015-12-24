## tool file

module Rastrum
  class Tool
    def process_file(filename)
     #begin processing
      doc = Document.new(filename)
      unless filename == "versionlog"
        doc.latex
        doc.lbptex
        doc.html
      end
    end
    def self.file_update(filename, status, ed_no)
        puts "performs #{status} procedure"
        puts filename
        doc = Document.new(filename)
        puts "setting ed number to #{ed_no}..."
        doc.set_edno(ed_no)
        puts "setting date..."
        doc.set_date
        puts "creating change entry and setting status..."
        doc.set_change(status: "#{status}", ed_no: ed_no, valscheme: "lbp-0.0.1")
        puts "saving changes..."
        doc.save(filename)

       
    end
    def self.file_update_dev(filename, ed_no)
        puts "updates version num to #{ed_no}"
        puts filename
        doc = Document.new(filename)
        puts "setting ed number to #{ed_no}..."
        doc.set_edno(ed_no)
        puts "saving changes..."
        doc.save(filename)
    end
    
    def self.versionlog_update(desc, ed_no)
      if !File.exist?('versionlog.xml')
        VersionDoc.create_version_log
      end
      doc = VersionDoc.new('versionlog.xml')
      doc.versionentry(desc, ed_no)
      doc.save("versionlog.xml")
    end
    
    def self.next_version
      f = File.open("transcriptions.xml", "r")  
      doc = Nokogiri::XML(f)
      f.close
      next_version = doc.xpath('/transcriptions/@next-version').text
      return next_version
    end
    def self.check_version
      Dir.foreach('.') do |filename|
        # skip ., .., .git
        next if filename == '.' or filename == '..' or filename == '.git' or filename.include? ".md" or filename == "Rastrumfile" or filename == "transcriptions.xml" or filename == "processed"
        # do work on real items
        doc = Document.new(filename)
        version = doc.version
        if version.split("-").first == self.next_version
          return false
        end
      end
    end
    def self.dirname
      name = Dir.pwd.split("/").last
      return name
    end
  end
end