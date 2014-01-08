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

    # output_result(comment, header, master_summary, out_file, raw_flag)
  end # def

  def process(in_dir)
    files = []
    Dir.foreach(in_dir) do |filename|
      file_path = in_dir + File::SEPARATOR + filename
      files.push DistanceFile.new(file_path) unless filename =~ /^\.+$/ # skip . and ..
    end 
    pp files.first.data
    i = 0
    files.each do |file|
      file.data.each do |row|
        # pp row
        i += 1
        exit if i == 10
      end
    end
  end

  def output_result(*args)
    
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
