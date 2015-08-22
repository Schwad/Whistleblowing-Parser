require 'json'

class DataParser

  def hash_this_json(json_file)
    data_from(json_file).each_with_object(Hash.new []) do |element, hashed_data|
      hashed_data[element[10]] += [element]
    end
  end

  private

  def data_from(json_file)
    parse_this(json_file)["data"]
  end

  def parse_this(json_file)
    JSON.parse(File.read(json_file))
  end
end
