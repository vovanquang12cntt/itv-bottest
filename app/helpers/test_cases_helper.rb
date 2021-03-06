module TestCasesHelper
  def read_test_cases test_suit_id
    test_cases = []
    @big_id_tc = 0
    filename = "test_suit" + test_suit_id + ".xml"
    Dir.glob("#{Settings.dir_store_data}/user#{current_user.id}/test_suites/test_suit#{test_suit_id}/test_case*.xml").each do |file|
      test_suit_doc = Nokogiri::XML(File.open(file))
      test_suit_doc.xpath("TestCase").each do |tc|
        test_case = TestCase.new
        test_case.name = tc.at_xpath("Name").text
        test_case.id = tc.at_xpath("Id").text
        test_case.status = tc.at_xpath("Status").text
        @big_id_tc = @big_id_tc > test_case.id ? @big_id_tc : test_case.id
        test_cases << test_case
      end
    end
    return test_cases
  end

  def write_test_case_to_file_xml(test_case, test_suit_id)
    builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml.TestCase{
        xml.Id test_case.id
        xml.Name test_case.name
        xml.Status test_case.status
        xml.CreatedAt test_case.created_at
      }
    end

    File.open("#{Settings.dir_store_data}/user#{current_user.id}/test_suites/test_suit#{test_suit_id}/test_case#{test_case.id}.xml", "w+") do |file|
      file << builder.to_xml
    end
  end

  def load_test_cases_changed test_suit_id
    test_cases = read_test_cases test_suit_id
    test_case_changed = []
    test_cases.each do |tc|
      if tc.status == Settings.status.change
        test_case_changed << tc
      end
    end
    return test_case_changed
  end

  def updated_field_test_case test_case, test_suit_id
    doc_script = Nokogiri::XML(File.open("#{Settings.dir_store_data}/user#{current_user.id}/test_suites/test_suit#{test_suit_id}/test_case#{test_case['id']}.xml"));
    lsTestScript = []
    doc_script.xpath("//step").each do |script|

      objScript = {}
      objScript["name"] = script.at_xpath("name").text
      objScript["action_id"] = script.at_xpath("IdAction").text
      arguments = []
      script.xpath("arguments//argument").each do |arg|
        objArg = {}
        objArg["name"] = arg.at_xpath("name").text
        objArg["value"] = arg.at_xpath("value").text
        arguments << objArg
      end
      objScript["arguments"] = arguments
      lsTestScript << objScript
    end

    # write test case after updated field
    builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml.TestCase{
        xml.Id test_case['id']
        xml.Name test_case["name"]
        xml.Status  Settings.status.commited
        xml.CreatedAt Time.current
        xml.steps{
        lsTestScript.each do |script|
          items_step = script.to_a
          xml.step{
            xml.name items_step[0][1]
            xml.IdAction items_step[1][1]
            xml.arguments{
              args = items_step[2][1]
              for i in 0..args.length-1
                xml.argument{
                  xml.name args[i].to_a[0][0]
                  xml.value args[i].to_a[0][1]
                }
              end
            }
          }
        end
        }
      }
    end
    File.open("#{Settings.dir_store_data}/user#{current_user.id}/test_suites/test_suit#{test_suit_id}/test_case#{test_case['id']}.xml", "w+") do |file|
      file << builder.to_xml
    end
  end
end
