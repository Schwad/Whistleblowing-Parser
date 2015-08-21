require 'csv'
require 'json'
require_relative 'data_parser'


parser = DataParser.new
june_data = parser.hash_this_json 'data/june.json'
august_data = parser.hash_this_json 'data/august.json'


##### EXPECT LOTS OF DOWNSTREAM BUGS #####

@count = 1

def second_check(element, key)
   @payer_time = false
   @subject_line = false
   @amount_time = false
   august_data[key].each do |new_element|
      if element[-4..-2] == new_element[-4..-2] && element[-1].to_i == new_element[-1].to_i
        @payer_time = true
      elsif element[-5..-4] == new_element[-5..-4] && element[-1].to_i == new_element[-1].to_i
        if element[-3].to_i != new_element[-3].to_i
          @subject_line = true
        end
      elsif element[-5..-2] == new_element[-5..-2] && element[-1].to_i != new_element[-1].to_i
        @amount_time = true
      end
   end
   if @subject_line == true
     generate report(element, "SUBJECT ALTERED")
   elsif @payer_time == true
     generate_report(element, "PAYOR ALTERED")
   elsif @amount_time == true
      generate_report(element, "AMOUNT ALTERED")
   else
     generate_report(element, "ALTERED")
   end
end

def compare_key(key)
  if august_data[key] == []
    generate_report(key, "PAYEE DELETED")
  else

    june_data[key].each do |element|
      @checker = false
      august_data[key].each do |new_element|
        if element[-5..-2] == new_element[-5..-2] && element[-1].to_i == new_element[-1].to_i
          @checker = true
        end
      end
      if @checker == false
        second_check(element, key)
        puts "ERROR DETECTED"
      end
    end
  end
end

def generate_report(element, type)
  if type == "PAYEE DELETED"
    CSV.open("TRANSPARENCYREPORTJULY15DELETE.csv", "a") do |csv|
        csv << ["#{element}", "DELETED"]
    end
  elsif type == "AMOUNT ALTERED"
    CSV.open("TRANSPARENCYREPORTJULY15ALTERAMOUNT.csv", "a") do |csv|
          csv << ["#{element[1]}","#{element[9]}", "#{element[10]}", "#{element[11]}", "#{element[12]}", "#{element[13]}", "#{type}"]
        end
  elsif type == "SUBJECT ALTERED"

    CSV.open("TRANSPARENCYREPORTJULY15ALTERSUBJECT.csv", "a") do |csv|
          csv << ["#{element[1]}","#{element[9]}", "#{element[10]}", "#{element[11]}", "#{element[12]}", "#{element[13]}", "#{type}"]
        end
  elsif type == "PAYOR ALTERED"
    CSV.open("TRANSPARENCYREPORTJULY15ALTERPAYOR.csv", "a") do |csv|
          csv << ["#{element[1]}","#{element[9]}", "#{element[10]}", "#{element[11]}", "#{element[12]}", "#{element[13]}", "#{type}"]
        end
  else
    CSV.open("TRANSPARENCYREPORTJULY15ALTERGENERIC.csv", "a") do |csv|
          csv << ["#{element[1]}","#{element[9]}", "#{element[10]}", "#{element[11]}", "#{element[12]}", "#{element[13]}", "#{type}"]
    end
  end
   puts "#{type}"
end

june_data.keys.each do |key|
  if @count % 100 == 0
    puts "comparing #{@count} AT #{key}"
  end
  compare_key(key)
  @count += 1
end
