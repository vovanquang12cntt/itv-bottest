module TestSuitsHelper
  def write_test_suite_to_file_xml test_suites
    builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml.TestSuites{
        test_suites.each do |ts|
          xml.TestSuit{
            xml.Id ts["id"]
            xml.Name ts["name"]
            xml.UserId ts["user_id"]
            xml.CreatedAt ts["created_at"]
          }
        end
      }
    end

    File.open("lib/xml/test_suits/test_suits.xml", "w+") do |file|
      file << builder.to_xml
    end
  end
end
