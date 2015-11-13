require 'nokogiri'
require 'date'


module Rastrum
	class Document
		attr_reader :doc, :filename
		def initialize(filename)
			f = File.open("#{filename}", "r")  
    	@doc = Nokogiri::XML(f)
      @filename = filename
    	f.close
		end

		def save(filename)
			File.open("#{filename}",'w') do |f|
         @doc.write_xml_to f
       end
		end

    def version
      version = @doc.xpath('//tei:editionStmt/tei:edition/@n', {"tei" => "http://www.tei-c.org/ns/1.0"}).text
      return version
    end
    #set_edno is the setter corresponding to the version getter. 
    #it would be better if these names matched.
		def set_edno(ed_no)
		@doc.xpath('//tei:editionStmt/tei:edition/@n', {"tei" => "http://www.tei-c.org/ns/1.0"}).each do |node|
        puts ed_no
        node.content = ed_no    
        end
    end
    def set_date(date=nil)
    	doc.xpath('//tei:editionStmt/tei:edition/tei:date', {"tei" => "http://www.tei-c.org/ns/1.0"}).each do |node|
        if date == nil
            newDate = Date.today.to_s
        else
            newDate = date
        end
        d = Date.parse(newDate)
        formattedDate = d.strftime('%B %d, %Y')
        node['when'] = newDate
        node.content = formattedDate
      end
    end
    def set_date_orig(date=nil)
      doc.xpath('//tei:publicationStmt/tei:date', {"tei" => "http://www.tei-c.org/ns/1.0"}).each do |node|
        if date == nil
            newDate = Date.today.to_s
        else
            newDate = date
        end
        d = Date.parse(newDate)
        formattedDate = d.strftime('%B %d, %Y')
        node['when'] = newDate
        node.content = formattedDate
      end
    end
    def set_change(date: nil, who: nil, status: nil, ed_no: nil, desc: nil, collab: nil, valscheme: nil)
        if date == nil
            newDate = Date.today.to_s
        else
            newDate = date
        end
        
        ## this spacing is important to get (currently desired formatting)
        ## there is probably a more relable way to do this
    	change = "
        <change when='#{newDate}' who='#{who}' status='#{status}' n='#{ed_no}'>
    			<p>#{desc}</p>
    			<note type='status'>
    				<note type='collaboration'>#{collab}</note>
    				<note type='validating-schema'>#{valscheme}</note>
    			</note>
    		</change>"
    	@doc.xpath('//tei:revisionDesc/tei:listChange', {"tei" => "http://www.tei-c.org/ns/1.0"}).each do |node|
    	   node.prepend_child(change) 
        end
        self.set_status(status)
    end
    def set_status(status)
    	doc.xpath('//tei:revisionDesc/@status', {"tei" => "http://www.tei-c.org/ns/1.0"}).each do |node|
        node.content = status   
      end
    end
    def latex
        filenamestem = filename.split(".").first
        `mkdir -p processed/#{filenamestem}
        cd processed/#{filenamestem}
        
        # begin xslt conversion
        echo "Begin TEI to LaTeX conversion";
        saxon "-s:../../#{filename}" "-xsl:/Users/JCWitt/Desktop/lombardpress-print/lbp-latex-critical.xsl" "-o:#{filenamestem}.tex";
        
        #stream edit for unwanted spaces
        echo "Begin removing unwanted spaces"
        sed -i.bak -e 's/ \{1,\}/ /g' -e 's/{ /{/g' -e 's/ }/}/g' -e 's/ :/:/g' #{filenamestem}.tex
        echo "unwanted spaces removed"

        echo "Begin LaTeX to PDF conversion; placing PDF on the desktop";
        
        cd ../../`
    end
    def lbptex
      filenamestem = filename.split(".").first
      itemid = filenamestem.split("_").last
      `lbp-convert #{filenamestem} #{itemid}-#{Date.today.to_s}-#{self.version}`
    end
    def html
        filenamestem = filename.split(".").first
        `mkdir -p processed/#{filenamestem}
        cd processed/#{filenamestem}
        
        # begin xslt conversion
        echo "Begin TEI to LaTeX conversion";
        saxon "-s:../../#{filename}" "-xsl:/Users/JCWitt/WebPages/lombardpress2/xslt/default/critical/clean_view.xsl" "-o:#{filenamestem}.html";
        
        #stream edit for unwanted spaces
        echo "Begin removing unwanted spaces"
        sed -i.bak -e 's/ \{1,\}/ /g' -e 's/{ /{/g' -e 's/ }/}/g' -e 's/ :/:/g' #{filenamestem}.html
        echo "unwanted spaces removed"

        cd ../../`
    end
  end

  class Repo
    def self.stage
      `git add -A`
    end
    def self.commit(message)
      `git commit -m "#{message}"`
    end
    def self.version(version)
      `git tag v#{version}`
    end
    def self.push(remote='origin', branch='master')
      `git push #{remote} #{master}`
    end
    def self.full_update(version)
      self.stage
      self.commit("auto commit on version #{version} update")
      self.version(version)
      #self.push
    end
    def self.light_update(version)
      self.stage
      self.commit("auto commit on version #{version} update")
    end
  end
  class Tool
    def self.file_update(filename, status, ed_no)
        puts "performs #{status} procedure"
        puts filename
        doc = Document.new(filename)
        puts "setting ed number to #{ed_no}..."
        doc.set_edno(ed_no)
        puts "setting date..."
        doc.set_date
        puts "creating change entry and setting status..."
        doc.set_change(who: "auto", status: "#{status}", ed_no: ed_no, desc: "test", collab: "yes", valscheme: "lbp-0.0.1")
        puts "saving changes..."
        doc.save(filename)
        #begin processing
        doc.latex
        doc.lbptex
        doc.html
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
    def self.directory_update(status, ed_no)
      Dir.foreach('.') do |filename|
        # skip ., .., .git
        next if filename == '.' or filename == '..' or filename == '.git' or filename.include? ".md" or filename == "Rastrumfile" or filename == "transcriptions.xml" or filename == "processed"
        # do work on real items
        self.file_update(filename, status, ed_no)
      end
    end
    def self.directory_update_dev(ed_no)
      Dir.foreach('.') do |filename|
        # skip ., .., .git
        next if filename == '.' or filename == '..' or filename == '.git' or filename.include? ".md" or filename == "Rastrumfile" or filename == "transcriptions.xml" or filename == "processed"
        # do work on real items
        self.file_update_dev(filename, ed_no)
      end
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