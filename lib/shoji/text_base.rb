
require 'fastercsv'

require 'shoji/base'
require 'shoji/utf8_file'

class Shoji::TextBase < Shoji::Base
  ENCMAP = Hash.new('n').merge({
    'UTF-8' => 'u',
    'SHIFT-JIS' => 's',
    'EUC-JP' => 'e',
    'CP932' => 's'
  })
  def self.foreach(filename, opts = {}, &block)
    Shoji::UTF8File.convert filename do |path|
      limit = opts[:limit].to_i
      index = 0
      FasterCSV.foreach(path, fastercsv_opts) do |row|
        block.call(row)
        index += 1
        break if (limit > 0 && limit <= index)
      end
    end
  end
  def self.valid_file?(filename, opts = {})
    Shoji::UTF8File.convert filename do |path|
    end
  end
  def self.rows(filename, opts = {})
    rows = []
    self.foreach(filename, opts) do |row|
      rows << row
    end
    rows
  end
  def self.row_size(filename, opts = {})
    enc = ENCMAP[Shoji::UTF8File.guess_encoding(filename)]
    index = 0
    FasterCSV.foreach(filename, fastercsv_opts.merge({:encoding => enc})) do |row|
      index += 1
    end
    index
  end
  protected
  def self.fastercsv_opts; raise NoMethodError.new; end
  def self.first_line(filename)
    line = nil
    Shoji::UTF8File.convert filename do |path|
      File.foreach(path) do |l|
        line = l
        break
      end
    end
    line
  end
  def self.has_char?(filename, char)
    first_line(filename).include? char
  end

end
