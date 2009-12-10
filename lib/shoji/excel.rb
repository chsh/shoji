# Shoji

require 'spreadsheet'

require 'shoji/base'
class Shoji::Excel < Shoji::Base

  require 'shoji/excel/reader'

  READER = Shoji::Excel::Reader

  def self.foreach(filename, opts = {}, &block)
    raise 'Block must be exist.' unless block_given?
    READER.new(filename).foreach(opts, &block)
  end
  def self.valid_file?(filename)
    READER.valid_file? filename
  end

  def self.rows(filename, opts = {})
    READER.new(filename).rows(opts)
  end

  def self.row_size(filename, opts = {})
    READER.new(filename).row_size(opts)
  end

  def self.convert_to_hash(filename, opts = {})
    opts_for_parse = opts.slice(:sheet_index)
    opts_for_convert = opts.slice(:header)
    rows = self.rows(filename, opts)
    return {} if rows.size < 2
    list = []
    header = rows.shift
    header = opts_for_convert[:header] if opts_for_convert[:header]
    rows.each do |row|
      list << make_hash(header, row)
    end
    list
  end

  def initialize(filename)
    @filename = filename
  end

  def foreach(opts = {}, &block)
    self.class.foreach(@filename, opts, &block)
  end
  def valid_file?
    self.class.valid_file? @filename
  end
  def rows(opts = {})
    self.class.rows(@filename, opts)
  end
  def row_size(opts = {})
    self.class.row_size(@filename, opts)
  end
  def convert_to_hash(opts = {})
    self.class.convert_to_hash(@filename, opts)
  end

  private
  def self.process_rows(sheet, &block)
    sheet.each do |row|
      cells = cells_from_row(row)
      block.call(cells)
    end
  end
  def self.make_hash(header_columns, row_columns)
    h = {}
    header_columns.size.times do |i|
      h[header_columns[i]] = row_columns[i]
    end
    h
  end
end
