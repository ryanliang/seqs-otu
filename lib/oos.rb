module OOS
  COMMENT_LINE_NUM = 0
  HEADER_LINE_NUM  = 1
  OTU_PREFIX = 'denovo'
  DEFAULT_VALUE_LIMIT = 500

  def main
    if ARGV.count < 2
      print_usage
      exit
    end

    oos_dir, out_file = ARGV[0], ARGV[1]

    raw_flag = ARGV[-1] == '-r' ? true : false
    value_limit = (ARGV.count > 2 && ARGV[2] =~ /^[0-9]+$/) ? ARGV[2].to_i : DEFAULT_VALUE_LIMIT

    ARGV.clear
    
    result = process(oos_dir)
    master_summary, comment, header = result[:summary], result[:comment], result[:header]

    output_result(comment, header, master_summary, out_file, raw_flag, value_limit)
  end # def

  def process(oos_dir)
    master_summary ={}
    comment, header = '', ''

    Dir.foreach(oos_dir) do |filename|
      file_path = oos_dir + File::SEPARATOR + filename
      File.open(file_path, "r").each_with_index do |line, line_num|
        case line_num
        when COMMENT_LINE_NUM then comment = line
        when HEADER_LINE_NUM  then header  = line
        else
          otu_occur = OtuOccurance.new(line, OTU_PREFIX)
          if master_summary[otu_occur.otu_num].nil?
            master_summary[otu_occur.otu_num] = otu_occur
          else
            master_summary[otu_occur.otu_num].sum(otu_occur)
          end
        end
      end unless filename =~ /^\.+$/ # skip . and ..
    end # Dir
    {summary: master_summary.values.sort, comment: comment, header: header}
  end

  def print_usage
    puts "Incorrect number of parameters"
    puts "Usage:   oos.rb 'dir_to_oos_files' 'output_file_path [limit -r]"
    puts "Example: oos.rb 'C:\\temp\\ivy\\shared\\trialforsummarytable' 'c:\\temp\\ivy\\shared\\output.txt'"
    puts "Example: oos.rb 'C:\\temp\\ivy\\shared\\trialforsummarytable' 'c:\\temp\\ivy\\shared\\output.txt' 400 -r"
  end # def

  def output_result(*args)
    comment   = args[0]
    header    = args[1]
    summary   = args[2]
    file_path = args[3]
    raw_flag  = args[4]
    value_limit = args[5]

    File.open(file_path, 'w') do |file|
      file.write(comment)
      file.write(header)
      summary.each do |otu_occur|
        if raw_flag
          file.write(otu_occur.to_s)
        else
          unless otu_occur.all_value_less_than?(value_limit)
            otu_occur.replace_value_if_less_than_limit(value_limit, 0)
            file.write(otu_occur.to_s)
          end
        end
      end
    end
  end 

  class OtuOccurance
    include Comparable

    SEPARATOR = "\t"
    attr_reader \
      :raw_line_data, 
      :prefix, 
      :sample_summary,
      :acrued_summary,
      :otu_num
    
    def initialize(raw_line_data, prefix)
      @raw_line_data = raw_line_data
      @prefix = prefix
      parse_data
    end

    def sum(other_occur)
      other_summary = other_occur.sample_summary
      @acrued_summary.each_with_index do |o, ind|
        @acrued_summary[ind] += other_summary[ind]
      end
    end

    def to_s
      "#{prefix}#{otu_num.to_s}" + SEPARATOR + @acrued_summary.join(SEPARATOR) + "\n"
    end

    def all_value_less_than?(limit)
      @acrued_summary.each do |value|
        return false if value >= limit
      end
      result = true
    end

    def replace_value_if_less_than_limit(limit, replacement)
      @acrued_summary.each_with_index do |value, index|
        @acrued_summary[index] = replacement if value < limit
      end unless all_value_less_than?(limit)
    end

    def <=>(other)
      otu_num.to_s.to_i <=> other.otu_num.to_s.to_i
    end

    private
    def parse_data
      parsed = @raw_line_data.split(SEPARATOR)
      @otu_num = parsed[0].gsub(prefix, '').to_sym
      @sample_summary = parsed[1..-1]
      @sample_summary.map! { |o| o.to_i }
      @acrued_summary = @sample_summary
    end
  end

end # module OOS

include OOS
OOS::main

