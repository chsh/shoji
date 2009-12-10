

class Shoji::Base
  include Enumerable
  def self.foreach(filename, opts = {}, &block); raise NoMethodError.new; end
  def self.valid_file?(filename, opts = {}); raise NoMethodError.new; end
  def self.rows(filename, opts = {}); raise NoMethodError.new; end
  def self.row_size(filename, opts = {}); raise NoMethodError.new; end
  def self.valid_content?(content, opts = {})
    tf = Tempfile.new("shoji-base.#{$$}.data")
    tf.write content
    tf.close
    status = self.valid_file?(tf.path)
    tf.close(true)
    status
  end
  
  def each(&block)
    self.class.foreach(@filename, {}, &block)
  end
  def self.foreach_hash(filename, opts = {}, &block)
    header = nil
    self.foreach(filename, opts) do |row|
      if header
        hash = Hash[*[header, row].transpose.flatten]
        block.call(hash)
      else
        header = row.map(&:to_sym)
      end
    end
  end
  
end
