module EC
  OTU_PREFIX = 'otu'

  def main
    if ARGV.count < 3
      print_usage
      exit
    end

    desired_set_file, whole_dna_set_file, ouput_file = ARGV[0], ARGV[1], ARGV[2]
    ARGV.clear
    
    desired_set   = read_file_into_array(desired_set_file)
    whole_dna_set = read_file_into_array(whole_dna_set_file)
    result        = process(desired_set, whole_dna_set)
    output_result(result, ouput_file)
  end

  def process(desired_set, whole_dna_set)
    result = []
    desired_set.each do |ds|
      index = get_otu_num(ds)
      if index < (whole_dna_set.count + 1) / 2
        result << '<' + ds
        result << whole_dna_set[2 * index + 1]
      end
    end
    result
  end

  def print_usage
    puts "Incorrect number of parameters"
    puts "Usage:   ec.rb 'desired_set.txt' 'wholeset.txt' output.txt"
    puts "Example: ec.rb 'C:\\temp\\desired_set2.txt' 'c:\\temp\\wholeset_Test_2.txt' 'c:\\temp\\output.txt'"
  end # def

  def output_result(result, ouput_file)
    File.open(ouput_file, 'w') do |f|
      result.each { |line| f.write(line) }
    end
  end

  private

  def read_file_into_array(file_path)
    result = []
    File.open(file_path, 'r') do |f|
      f.each_line { |l| result << l }
    end
    result
  end

  def get_otu_num(otu)
    otu.downcase.delete(OTU_PREFIX).to_i
  end
end # module EC

include EC
EC::main
