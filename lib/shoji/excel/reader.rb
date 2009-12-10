
require 'tempfile'
require 'spreadsheet'

class Shoji::Excel::Reader

  def initialize(filename_or_content)
    @filename_or_content = filename_or_content
  end

  def self.valid_file?(filename_or_content)
    valid = true
    begin
      Spreadsheet.open(filename_or_content) do |workbook|
      end
    rescue
      valid = false
    end
    valid
  end

  def rows(opts = {})
    r = []
    foreach(opts) do |row|
      r << row
    end
    r
  end

  def row_size(opts = {})
    return @row_size if @row_size
    sheet_index = opts[:sheet_index] || 0
    idx = 0
    Spreadsheet.open(@filename_or_content) do |workbook|
      num_sheets = workbook.worksheets.size
      return [] if num_sheets == 0 || num_sheets <= sheet_index
      worksheet = workbook.worksheet(sheet_index)
      @row_size = worksheet.row_count
      @row_size -= 1 if opts[:use_header]
    end
    @row_size
  end

  def foreach(opts = {}, &block)
    sheet_index = opts[:sheet_index] || 0
    Spreadsheet.open(@filename_or_content) do |workbook|
      num_sheets = workbook.worksheets.size
      return [] if num_sheets == 0 || num_sheets <= sheet_index
      worksheet = workbook.worksheet(sheet_index)
      process_rows(worksheet, opts, &block)
    end
  end

  private
  def process_rows(worksheet, opts = {}, &block)
    max = opts[:limit]
    idx = 0
    idx -= 1 if opts[:use_header]
    worksheet.each do |row|
      cells = []
      row.each do |c|
        cells << c
      end
      block.call(cells)
      idx += 1
      break if max && max <= idx
    end
  end

end
