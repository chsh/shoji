
require 'zip/zipfilesystem'
require 'nokogiri'

class Shoji::ODS::Reader

  attr_accessor :skip_empty_row

  def self.open(filename, sheet_name = nil, &block)
    reader = new(filename)
    reader.skip_empty_row = false
    reader.process_book(sheet_name, &block)
  end

  def initialize(filename)
    @filename = filename
  end

  def process_book(sheet_name = nil, &block)
    docbytes = read_from_zip_content_xml(@filename)

    doc = Nokogiri::XML(docbytes)
    path = "//table:table"
    path += "[@table:name='#{sheet_name}']" if sheet_name
    ws = doc.at_xpath path
    process_sheet(ws, &block)
  end

  def valid_file?
    valid = true
    begin
      read_from_zip_content_xml(@filename, true)
    rescue
      valid = false
    end
    valid
  end
  def rows(opts = {})
    result = []
    process_book(opts[:sheet]) do |row|
      result << row
    end
    result
  end
  def self.valid_file?(filename)
    new(filename).valid_file?
  end

  def process_sheet(sheet, &block)
    sheet.xpath('table:table-row').each do |row|
      rowreps = row['table:number-rows-repeated'] || '1'
      rowreps = rowreps.to_i
      process_row(rowreps, row, &block)
    end
  end

  def process_row(rowreps, row, &block)
    cols = []
    index = 0
    has_value = false
    row.xpath('table:table-cell').each do |cell|
      tv = typed_value cell
      if tv && tv != ''
        cols[index] = tv
        has_value = true
      else
        cols[index] = ''
      end
      colreps = cell['number-columns-repeated']
      if colreps
        colreps.to_i.times do |num|
          cols[index + num] = cols[index]
        end
        index = index + colreps.to_i
      else
        index = index + 1
      end
    end
    rowreps.times do |num|
      if has_value
        block.call(cols)
      elsif !skip_empty_row
        block.call(cols)
      end
    end
  end

  private
  def typed_value(cell)
    case cell['value-type']
    when nil then nil
    when 'date' then Date.parse cell['date-value']
    when 'currency', 'float' then cell['value'].to_f
    else cell.text
    end
  end
  def read_from_zip_content_xml(filename, verify_only = false)
    raise "File:#{filename} doesn't exist." unless File.exist? filename
    docbytes = nil
    Zip::ZipFile.open(filename) do |zipfile|
      raise "content.xml doesn't exist in #{filename}." unless zipfile.find_entry('content.xml')
      docbytes = zipfile.read('content.xml') unless verify_only
    end
    docbytes
  end
end
