
require 'shoji/text_base'

class Shoji::TSV < Shoji::TextBase
  def self.valid_file?(filename)
    has_char? filename, "\t"
  end
  protected
  def self.fastercsv_opts
    { :col_sep => "\t" }
  end
end
