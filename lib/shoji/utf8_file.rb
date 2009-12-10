require 'tempfile'
require 'nkf'
require 'iconv'
 
class Shoji::UTF8File
  def self.convert(filename, &block)
    encoding = guess_encoding(filename)
    raise "Couldn't detect encoding" unless encoding
    fp = make_instance(filename, encoding)
    if block_given?
      begin
        yield(fp.path)
      ensure
        fp.delete
      end
    else
      fp
    end
  end
  attr_reader :tempfile
  def initialize(source, type)
    @filename = nil; @tempfile = nil
    case type
    when :filename then @filename = source
    when :tempfile then @tempfile = source
    else raise "Unexpected type=#{type}"
    end
  end
  def path
    return @filename if @filename
    @tempfile.path
  end
  def delete
    return false unless @tempfile
    @tempfile.close(true)
    @tempfile = nil
    true
  end
  def self.guess_encoding(filename)
    NKF2ICONV[NKF.guess(read_lines(filename, 3))]
  end
  private
  NKF2ICONV = {
    NKF::UTF8 => 'UTF-8',
    NKF::SJIS => 'SHIFT-JIS',
    NKF::EUC => 'EUC-JP',
    NKF::JIS => 'ISO-2022-JP',
    NKF::ASCII => 'UTF-8'
  }
  def self.winfile?(filename)
    line = read_lines(filename, 1)
    if line =~ /\r\n$/
      true 
    else
      false
    end
  end
  def self.make_instance(filename, encoding)
    return new(filename, :filename) if encoding == 'UTF-8'
    if winfile?(filename) && encoding == 'SHIFT-JIS'
      encoding = 'CP932'
    end
    tf = Tempfile.new('file-path')
    tf.write Iconv.conv('UTF-8', encoding, File.read(filename))
    tf.close
    new(tf, :tempfile)
  end
  def self.read_lines(filename, max = 1)
    lines = []
    index = 0
    File.foreach(filename) do |line|
      lines << line
      index += 1
      break if index >= max
    end
    lines.join('')
  end
end
