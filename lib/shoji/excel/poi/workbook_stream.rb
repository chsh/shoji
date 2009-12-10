
require 'tempfile'

require 'shoji/java_loader'

class Shoji::Excel::POI::WorkbookStream
  def initialize(filename, &block)
    raise "Block must be given." unless block_given?
    run_process(filename, &block)
  end

  def self.open(filename, &block)
    self.new(filename, &block)
  end
  def self.valid_file?(filename)
    valid = true
    begin
      Shoji::Excel::POI::WorkbookStream.new(filename) { |wb| }
    rescue => e
      valid = false
    end
    valid
  end

private
  class InternalJavaClassLoader
    @@file_input_stream = nil
    @@workbook_factory = nil
    def file_input_stream
      @@file_input_stream ||= Shoji::JavaLoader.import 'java.io.FileInputStream'
    end
    def byte_array_input_stream
      @@byte_array_input_stream ||= Shoji::JavaLoader.import 'java.io.ByteArrayInputStream'
    end
    def workbook_factory
      @workbook_factory ||= Shoji::JavaLoader.import 'org.apache.poi.ss.usermodel.WorkbookFactory'
    end
  end
  @@class_loader = InternalJavaClassLoader.new
  def run_process(filename, &block)
    fis = @@class_loader.file_input_stream.new(filename)
    block.call(@@class_loader.workbook_factory.create(fis))
    fis.close
  end
end
