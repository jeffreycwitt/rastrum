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
    def set_change(date: nil, status: nil, ed_no: nil, valscheme: nil)
        if date == nil
            newDate = Date.today.to_s
        else
            newDate = date
        end
        
        ## this spacing is important to get (currently desired formatting)
        ## there is probably a more relable way to do this
        if @filename == 'versionlog.xml'
          change = "
          <change when='#{newDate}' status='#{status}' n='#{ed_no}' corresp='versionlog.xml#v#{ed_no}'/>"
        else
          change = "
        <change when='#{newDate}' status='#{status}' n='#{ed_no}' corresp='versionlog.xml#v#{ed_no}'>
          <note type='validating-schema'>#{valscheme}</note>
      	</change>"
        end
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
end



