
# meta class of excel, ods, csv and tsv processor.


class Shoji

  autoload :Excel, 'shoji/excel'
  autoload :CSV, 'shoji/csv'
  autoload :TSV, 'shoji/tsv'
  autoload :ODS, 'shoji/ods'

  class_eval do
    [:foreach, :foreach_hash, :valid_file?, :valid_content?, :rows, :row_size].each do |meth|
      eval <<EOL
def self.#{meth}(*args, &block)
  klass = class_from_params(*args, &block)
  klass.send(:#{meth}, *args, &block)
end
EOL
    end
  end

  def initialize(filename, opts = {}, &block)
    @filename = filename
    @opts = opts
    if block_given?
      yield(self)
    end
  end
  def foreach(opts = {}, &block)
    self.clcass.foreach(@filename, opts, &block)
  end
  def valid_file?(opts = {})
    self.class.valid_file?(@filename, opts)
  end
  def valid_content?(opts = {})
    self.class.valid_content?(@filename, opts)
  end

  def row_size(opts = {})
    self.class.row_size(@filename, opts)
  end
  def rows(opts = {})
    self.class.rows(@filename, opts)
  end

  private
  def self.detect_class_from_filename_or_content(filename)
    klass = detect_class_from_filename(filename)
    return klass if klass
    detect_class_from_content(filename)
  end
  def self.detect_class_from_filename(filename)
    @@ext2class ||= build_ext2class
    @@ext2class[File.extname(filename).upcase]
  end
  def self.build_ext2class
    {
      '.XLS' => Shoji::Excel,
      '.CSV' => Shoji::CSV,
      '.TSV' => Shoji::TSV,
      '.ODS' => Shoji::ODS
    }
  end
  def self.detect_class_from_content(filename)
    if binary_file? filename
      # Try to check valid xls.
      return Shoji::Excel if Shoji::Excel.valid_file? filename
    else
      line = first_line(filename)
      case line
      when /\t/ then Shoji::TSV
      when /,/ then Shoji::CSV
      else
        nil
      end
    end
  end
  def self.class_from_params(*args)
    filename = args[0]
    opts = args[1] || {}
    case opts[:type]
    when nil, :auto then detect_class_from_filename_or_content(filename)
    when :excel, :xls then Shoji::Excel
    when :csv then Shoji::CSV
    when :tsv, :tabtext, :tab_text, :tab then Shoji::TSV
    else "Unexpected type value=#{opts[:type]}"
    end
  end
  def self.binary_file?(filename)
    buf = nil
    File.open(filename, 'rb') do |f|
      buf = f.read(256)
    end
    buf.index("\0") ? true : false
  end
  def self.first_line(filename)
    line = nil
    File.foreach(filename) do |l|
      line = l
      break
    end
    line
  end
end
