
require 'tempfile'

class Shoji::Excel::POI::Reader
  
  def initialize(filename)
    @regulator = Shoji::Excel::POI::CellRegulator.new
    if content? filename
      @tempfile = Tempfile.new("shoji.#{$$}.xls")
      @tempfile.write filename
      @tempfile.close
      @filename = @tempfile.path
    else
      @filename = filename
    end
  end
  
  def rows(opts = {})
    sheet_index = opts[:sheet_index] || 0
    r = []
    Shoji::Excel::POI::WorkbookStream.open(@filename) do |wb|
      num_sheets = wb.getNumberOfSheets()
      return [] if num_sheets == 0 || num_sheets <= sheet_index
      sh = wb.getSheetAt(sheet_index)
      max = opts[:limit]
      idx = 0
      idx -= 1 if opts[:use_header] 
      process_rows(sh) do |row|
        r << row
        idx += 1
        break if max && max <= idx
      end
    end
    r
  end
  def row_size(opts = {})
    return @row_size if @row_size
    sheet_index = opts[:sheet_index] || 0
    idx = 0
    Shoji::Excel::POI::WorkbookStream.open(@filename) do |wb|
      num_sheets = wb.getNumberOfSheets()
      return [] if num_sheets == 0 || num_sheets <= sheet_index
      sh = wb.getSheetAt(sheet_index)
      idx -= 1 if opts[:use_header] 
      process_rows(sh) do |row|
        idx += 1
      end
    end
    @row_size = idx
  end
  
  def foreach(opts = {}, &block)
    sheet_index = opts[:sheet_index] || 0
    Shoji::Excel::POI::WorkbookStream.open(@filename) do |wb|
      num_sheets = wb.getNumberOfSheets()
      return [] if num_sheets == 0 || num_sheets <= sheet_index
      sh = wb.getSheetAt(sheet_index)
      process_rows(sh, &block)
    end
  end
  
  private
  def process_rows(sh, &block)
    (sh.getLastRowNum() + 1).times do |i|
      row = sh.getRow(i)
      cells = cells_from_row(row)
      block.call(cells)
    end
  end
  
  def cells_from_row(row)
    return [] unless row
    cn_first = row.getFirstCellNum()
    return [] if cn_first < 0
    cells = []
    cn_first.times do
      cells << nil
    end
     (cn_first ... row.getLastCellNum()).each do |i|
      cell = row.getCell(i)
      unless cell
        cells << nil
        next
      end
      cells << @regulator.regulate(cell)
    end
    cells
  end
  def content?(filename)
    filename.size > 255 && filename[-4,4].upcase != '.XLS'
  end
end
