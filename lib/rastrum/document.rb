require 'nokogiri'
require 'date'
#require 'rastrum'

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
        puts filename
        puts "Old edition was #{node}"
        node.content = ed_no    
        puts "Edition number has been changed to #{ed_no}"
     	end
    end
    def set_date(date)
    	doc.xpath('//tei:editionStmt/tei:edition/tei:date', {"tei" => "http://www.tei-c.org/ns/1.0"}).each do |node|
        puts "Old date was #{node.child}"
        newDate = "#{date}"
        d = Date.parse(newDate)
        formattedDate = d.strftime('%B %d, %Y')
        node['when'] = newDate
        node.content = formattedDate
        puts "Date was changed to #{formattedDate}"
      end
    end
    def set_change(date, who, status, ed_no, desc, collab, valscheme)
    	change = "<change when='#{date}' who='#{who}' status='#{status}' n='#{ed_no}'>
    							<p>#{desc}</p>
    							<note type='status'>
    								<note type='collaboration'>#{collab}</note>
    								<note type='validating-schema'>#{valscheme}</note>
    							</note>
    						</change>"
    		doc.xpath('//tei:RevisionDesc/listChange', {"tei" => "http://www.tei-c.org/ns/1.0"}).each do |node|
        	node.prepend_child(change)
      end

    end
    def set_status(status)
    	doc.xpath('//tei:RevisionDesc/@status', {"tei" => "http://www.tei-c.org/ns/1.0"}).each do |node|
        node.content = status   
      end
    end
  end
end