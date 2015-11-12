require 'nokogiri'
require 'date'


module Rastrum
	class Document
		attr_reader :doc 
		def initialize(filename)
			f = File.open("#{filename}", "r")  
    	@doc = Nokogiri::XML(f)
    	f.close
		end

		def save(filename)
			File.open("#{filename}",'w') do |f|
         @doc.write_xml_to f
       end
		end

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
    	doc.xpath('//tei:RevisionDesc/@status', {"tei" => "http://www.tei-c.org/ns/1.0"}).each do |node|
        node.content = status   
      end
    end
  end
end