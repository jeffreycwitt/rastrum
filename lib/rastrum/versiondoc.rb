# version doc

module Rastrum
  class VersionDoc < Document
    def versionentry(desc, ed_no)
      ## this spacing is important to get (currently desired formatting)
      ## there is probably a more relable way to do this
      change = "
      <div xml:id='v#{ed_no}'>
        <head>Description of changes for v#{ed_no}</head>
        <p>#{desc}</p>
      </div>"
      @doc.xpath('//tei:body/tei:div', {"tei" => "http://www.tei-c.org/ns/1.0"}).each do |node|
        node.prepend_child(change) 
      end
    end
    def self.create_version_log
      #gets teiHeader Information
      
      title = "Version Log"
      publisher = "LombardPress"
      
      #gets version entry information
      newDate = Date.today.to_s
      d = Date.parse(newDate)
      formattedDate = d.strftime('%B %d, %Y')
      
      #builds document
      builder = Nokogiri::XML::Builder.new do |xml|   
      xml.TEI("xmlns" => "http://www.tei-c.org/ns/1.0"){
          xml.teiHeader {
              xml.fileDesc{
                  xml.titleStmt{
                      xml.title "#{title}"
                  }
                  xml.editionStmt{
                      xml.edition('n' => "") {
                          xml.date('when' => "#{newDate}") {xml.text "#{formattedDate}"}
                          }
                      }
                  xml.publicationStmt{
                      xml.publisher "#{publisher}"
                      xml.availability("status" => "free") {
                          xml.p "Published under a Creative Commons Attribution ShareAlike 3.0 License"

                      }
                      xml.date("when" => "#{newDate}") {xml.text "#{formattedDate}"}
                  }   
                  xml.sourceDesc {
                      xml.p "born digital"
                  }
              }
              xml.revisionDesc("status" => "draft"){
                xml.listChange {

                }
              }
          }
          xml.text_ {
              xml.body {
                  xml.div('xml:id' => "versionlog")  {

                  }
                }
              }
          }
      end
      #writes and saves document to file
      o = File.new("versionlog.xml", "w")
      o.write(builder.to_xml)
      o.close
    end
  end
end