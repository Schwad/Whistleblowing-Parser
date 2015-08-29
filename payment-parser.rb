require 'csv'
require 'json'

puts "Firing up script..."

def sets_old_data_to_memory
  puts "setting old"
  file = File.read('rows.json')
  old_data = JSON.parse(file)
  puts "set array"
  puts "setting hash"
  @old_hash = Hash.new []
  old_data["data"].each do |element|
    @old_hash[element[10]] += [element]
  end
  puts "Hash of old data is set."
end

def sets_new_data_to_memory
  puts "Reading in new data..."
  file = File.read('rowsnew.json')
  new_data = JSON.parse(file)
  puts "Setting hash of new data..."
  @new_hash = Hash.new []
  new_data["data"].each do |element|
    @new_hash[element[10]] += [element]
  end
  puts "Hash of new data set."
end

def second_check(element, key)
   @new_hash[key].each do |new_element|

      #Checks for change in payor
      if element[-4..-2] == new_element[-4..-2] && element[-1].to_i == new_element[-1].to_i
       generate_report(element, new_element, "PAYOR ALTERED")
      end

      #Checks for change in subject
      if element[-5..-4] == new_element[-5..-4] && element[-1].to_i == new_element[-1].to_i
        if element[-3].to_i != new_element[-3].to_i
          generate_report(element, new_element, "SUBJECT ALTERED")
        end
      end

      #Checks for change in amount
      if element[-5..-2] == new_element[-5..-2] && element[-1].to_i != new_element[-1].to_i
        generate_report(element, new_element, "AMOUNT ALTERED")
      end
   end
end

def compare_key(key)
  if @new_hash[key] == []
    generate_report(key, "PAYEE DELETED")
  else
    @old_hash[key].each do |element|
      @checker = false
      @new_hash[key].each do |new_element|
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

def generate_report(element, new_element, type)

  case type
  when  "PAYEE DELETED"
    CSV.open("TRANSPARENCYREPORTJULY15DELETE.csv", "a") do |csv|
        csv << ["#{element}", "DELETED"]
    end
  when "AMOUNT ALTERED"
    CSV.open("TRANSPARENCYREPORTJULY15ALTERAMOUNT.csv", "a") do |csv|
          csv << ["#{element[1]}","#{element[9]}", "#{element[10]}", "#{element[11]}", "#{element[12]}", "#{element[13]}", "#{new_element[1]}","#{new_element[9]}", "#{new_element[10]}", "#{new_element[11]}", "#{new_element[12]}", "#{new_element[13]}", "#{type}"]
        end
  when "SUBJECT ALTERED"

    CSV.open("TRANSPARENCYREPORTJULY15ALTERSUBJECT.csv", "a") do |csv|
          csv << ["#{element[1]}","#{element[9]}", "#{element[10]}", "#{element[11]}", "#{element[12]}", "#{element[13]}", "#{new_element[1]}","#{new_element[9]}", "#{new_element[10]}", "#{new_element[11]}", "#{new_element[12]}", "#{new_element[13]}", "#{type}"]
        end
  when "PAYOR ALTERED"
    CSV.open("TRANSPARENCYREPORTJULY15ALTERPAYOR.csv", "a") do |csv|
          csv << ["#{element[1]}","#{element[9]}", "#{element[10]}", "#{element[11]}", "#{element[12]}", "#{element[13]}", "#{new_element[1]}","#{new_element[9]}", "#{new_element[10]}", "#{new_element[11]}", "#{new_element[12]}", "#{new_element[13]}", "#{type}"]
        end
  else
    CSV.open("TRANSPARENCYREPORTJULY15ALTERGENERIC.csv", "a") do |csv|
          csv << ["#{element[1]}","#{element[9]}", "#{element[10]}", "#{element[11]}", "#{element[12]}", "#{element[13]}", "#{new_element[1]}","#{new_element[9]}", "#{new_element[10]}", "#{new_element[11]}", "#{new_element[12]}", "#{new_element[13]}", "#{type}"]
    end
  end
   puts "#{type}"
end

def run_script
  sets_old_data_to_memory
  sets_new_data_to_memory
  count = 1
  @old_hash.keys.each do |key|
    if count % 100 == 0
      puts "comparing #{count} AT #{key}"
    end
    compare_key(key)
    count += 1
  end
end

run_script
