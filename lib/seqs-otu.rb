require 'pp'

module Seqsotu
  module Run

    def main
      if ARGV.count != 3
        print_usage
        exit
      end

      otu_file, seq_file, out_file = ARGV[0], ARGV[1], ARGV[2]
      ARGV.clear

      files = {otu_file: otu_file, seq_file: seq_file, out_file: out_file}

      print_help
      
      initialized = false      

      while input = gets
        input = input.strip
        case true
        when input == 'h'
          print_help
        when input == 'e'
          exit
        when is_i?(input)
          begin
            process(files.merge({ otu_num: input.to_i }), initialized)
            puts 'output file is ready. Or type another otu number to search again:'
            initialized = true
          rescue Exception => e
            puts "Error: " + e.message
            exit
          end
        else
          puts 'Error: command option not valid.'
          print_help
        end
      end # while
    end # def

    def print_usage
      puts "Incorrect number of parameters"
      puts "Usage:   seqs-otu.rb 'otu_file_path' 'seqs_file_path' 'output_file_path"
      puts "Example: seqs-otu.rb 'c:/temp/ivy/seqs_otus.txt' 'c:/temp/ivy/seqs.txt' 'c:/temp/ivy/output.txt'"
    end

    def print_help
      puts "type an otu number to search for sequence and write to output file"
      puts "type h for help"
      puts "type e to exit program"
    end

    def process(opt={}, initialized = false)
      otu_file_path = opt[:otu_file]
      seq_file_path = opt[:seq_file]
      out_file_path = opt[:out_file]
      otu_num       = opt[:otu_num]

      otu_file = File.open(otu_file_path, "r")
      otu_data_per_line = otu_data_by_num(otu_num, otu_file)
      cells = cells_from(otu_data_per_line)

      @seq_file_data = File.open(seq_file_path, "r").readlines unless initialized
      
      output_file = File.open(out_file_path, "w")

      cells.each do |cell|
        seq_name_ind = line_num_in_seq_file(cell.seq_id)[:seq_name_ind]
        seq_data_ind = line_num_in_seq_file(cell.seq_id)[:seq_data_ind]        
        output_file.write(@seq_file_data[seq_name_ind])
        output_file.write(@seq_file_data[seq_data_ind])        
      end
      output_file.close
      otu_file.close      
    end

    def otu_data_by_num(otu_num, file)
      file.each_line do |line|
        return line if line =~ /^#{otu_num}/
      end
    end

    def line_num_in_seq_file(seq_id)
      offset = 1 # index starts with 0
      {seq_name_ind: seq_id * 2 - 1 - offset,  
       seq_data_ind: seq_id * 2 - offset}
    end

    def is_i?(s)
      (s =~ /\A[0-9]*\Z/) ? true : false
    end

    # @return cells
    def cells_from(line)
      cells = []
      cells_raw = line.split(/\t/)
      otu = -1
      cells_raw.each_with_index do |raw_cell_data, ind|
        if ind == 0
          otu = raw_cell_data.to_i
        else
          cell = Cell.new(raw_cell_data, otu)
          cells.push(cell)
        end
      end
      cells
    end

  end # Run

  class Cell
    attr_reader :seq_id, :raw_data, :otu

    def initialize(raw_data, otu)
      @raw_data = raw_data
      @otu      = otu
    end

    def seq_id
      i = @raw_data.index('_') + 1
      @raw_data[i..-1].to_i
    end
  end # class Cell

end # Seqsotu

include Seqsotu::Run
Seqsotu::Run::main
