require 'helper'

FILEPATH = File.dirname(__FILE__) + "/files"

class TestShoji < Test::Unit::TestCase

  should "excel: load all rows" do
    reader = Shoji::Excel::POI::Reader.new("#{FILEPATH}/test01.xls")
    rows = reader.rows
    assert_equal [Date.parse('2009/2/1'), Date.parse('1998/2/1'),
    Date.parse('2008/3/1'), nil], rows[0]
    assert_equal ["アルファ", "alpha", 300, 123.456], rows[1]
  end
  
  should "excel: process foreach row" do
    reader = Shoji::Excel::POI::Reader.new("#{FILEPATH}/test01.xls")
    first = true
    reader.foreach do |cells|
      if first
        assert_equal [Date.parse('2009/2/1'), Date.parse('1998/2/1'),
        Date.parse('2008/3/1'), nil], cells
        first = false
        next
      end
      assert_equal ["アルファ", "alpha", 300, 123.456], cells
    end
  end

  should "csv: load all rows" do
    rows = Shoji::CSV.rows("#{FILEPATH}/test01.csv")
    assert_equal 2, rows.size
    rows = Shoji::CSV.rows("#{FILEPATH}/test01.csv", :limit => 1)
    assert_equal 1, rows.size
  end

  should "csv: process foreach row" do
    first = true
    Shoji::TSV.foreach "#{FILEPATH}/test01.tsv" do |cells|
      if first
        assert_equal ['いろは', 'abc', 'ほへと'], cells
        first = false
        next
      end
      assert_equal ["123", "あいう", "8月20日"], cells
    end
  end

  should "tsv: load all rows" do
    rows = Shoji::TSV.rows("#{FILEPATH}/test01.tsv")
    assert_equal 2, rows.size
    rows = Shoji::TSV.rows("#{FILEPATH}/test01.tsv", :limit => 1)
    assert_equal 1, rows.size

  end

  should "tsv: process foreach row" do
    first = true
    Shoji::TSV.foreach "#{FILEPATH}/test01.tsv" do |cells|
      if first
        assert_equal ['いろは', 'abc', 'ほへと'], cells
        first = false
        next
      end
      assert_equal ["123", "あいう", "8月20日"], cells
    end
  end

  should "autodetect: load all rows" do
    rows = Shoji.rows("#{FILEPATH}/testxls.data")
    assert_equal 2, rows.size
    assert_equal [Date.parse('2009/2/1'), Date.parse('1998/2/1'),
    Date.parse('2008/3/1'), nil], rows[0]
    rows = Shoji.rows("#{FILEPATH}/testcsv.data")
    assert_equal 2, rows.size
    assert_equal ['いろは', 'abc', 'ほへと'], rows[0]
    rows = Shoji.rows("#{FILEPATH}/testtsv.data")
    assert_equal 2, rows.size
    assert_equal ['いろは', 'abc', 'ほへと'], rows[0]
  end
end
