require 'pp'
module Distance
  HEADER_LINE_NUM = 0
  SEPARATOR = "\t"

  def main
    if ARGV.count < 2
      print_usage
      exit
    end

    in_dir, out_file = ARGV[0], ARGV[1]
    ARGV.clear
    
    result = process(in_dir)
    output_result(out_file, result)
  end # def

  def process(in_dir)
    files = []
    Dir.foreach(in_dir) do |filename|
      file_path = in_dir + File::SEPARATOR + filename
      files.push DistanceFile.new(file_path) unless filename =~ /^\.+$/ # skip . and ..
    end
    
    sample_file = files.first
    row = Array.new(sample_file.data.first.data.count, 0)
    file_sum = Array.new(sample_file.data.count){ row.dup }
    
    files.each do |file|
      file.data.each_with_index do |row, y|
        row.data.each_with_index do |col, x|
          file_sum[y][x] += file.value_at(y, x)
        end
      end
    end

    file_sum.each_with_index do |row, ind|
      row.unshift(sample_file.data[ind].row_header)
    end

    header = sample_file.header.split(SEPARATOR).map { |e| e.strip }
    file_sum.unshift(header)
    
    file_sum
  end

  def output_result(*args)
    output_file = args[0]
    file_sum    = args[1]

    File.open(output_file, 'w') do |file|
      file_sum.each_with_index do |row, i|
        file.write(row.join(SEPARATOR))
        file.write("\n") unless i + 1 == file_sum.count
      end
    end
  end

  def print_usage
    puts "Incorrect number of parameters"
    puts "Usage:   distance.rb 'dir_to_distance_files' 'output_file_path"
    puts "Example: distance.rb 'C:\\temp\\ivy\\shared\\trialforsummarytable' 'c:\\temp\\ivy\\shared\\output.txt'"
  end # def

  class DistanceFile
    attr_reader :header, :data

    def initialize(file_path)
      @data = []
      File.open(file_path, 'r').each_with_index do |line, ind|
        case ind
        when Distance::HEADER_LINE_NUM then @header = line
        else
          @data.push PairComparisonData.new(line)
        end
      end
    end # def

    def value_at(y, x)
      @data[y].data[x]
    end

  end # class

  class PairComparisonData
    attr_reader :data, :row_header

    def initialize(line)
      raw_data = parse_data(line)
      @row_header = raw_data.shift
      @data = raw_data.map { |e| e.to_f }
    end

    private
    def parse_data(line)
      line.split(Distance::SEPARATOR)
    end
  end

end

include Distance
Distance::main
