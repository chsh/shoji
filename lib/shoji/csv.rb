
require 'shoji/text_base'

class Shoji::CSV < Shoji::TextBase
  def self.valid_file?(filename)
    has_char? filename, ','
  end
  protected
  def self.fastercsv_opts
    {}
  end
end
