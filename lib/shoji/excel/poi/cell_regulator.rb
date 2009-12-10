
module Shoji::Excel::POI; end
class Shoji::Excel::POI::CellRegulator

  CELL_TYPE_BLANK = 3
  CELL_TYPE_BOOLEAN = 4
  CELL_TYPE_ERROR = 5
  CELL_TYPE_FORMULA = 2
  CELL_TYPE_NUMERIC = 0
  CELL_TYPE_STRING = 1

  def self.regulate(cell)
    @@me ||= self.new
    @@me.regulate(cell)
  end

  public
  def regulate(cell)
    case cell.getCellType()
    when CELL_TYPE_BLANK; ''
    when CELL_TYPE_BOOLEAN; cell.getBooleanCellValue()
    when CELL_TYPE_ERROR; nil
    when CELL_TYPE_FORMULA; ''
    when CELL_TYPE_NUMERIC
       getDateOrNumericValue(cell);
    when CELL_TYPE_STRING
      cell.getStringCellValue()
    else
      raise "Unexpected cell type: #{cell.getType()}"
    end
  end

  def getDateOrNumericValue(cell)
    if date_util.isCellDateFormatted(cell) || isJapaneseDateFormat(cell)
      javaDateToRubyDate(cell.getDateCellValue())
    else
      getFixnumOrFloatValue(cell)
    end
  end

  def getFixnumOrFloatValue(cell)
    val = cell.getNumericCellValue()
    if val.to_i.to_f == val
      val.to_i
    else
      val
    end
  end

  def isJapaneseDateFormat(cell)
    style = cell.getCellStyle()
    return true if [30, 31, 32, 33, 55, 56, 57, 58].include?(style.getDataFormat())
    format_string = style.getDataFormatString()
    return false unless format_string
    hasJapaneseDateExpression(format_string)
  end

  def hasJapaneseDateExpression(format_string)
    format_string =~ /[年月日時分秒]/
  end

  def javaDateToRubyDate(jd)
    ttd = jd.getTime()/1000
    return nil if ttd < 0
    t = Time.at(jd.getTime()/1000)
    if t.hour == 0 && t.min == 0 && t.sec == 0
      return Date.parse("#{t.year}/#{t.month}/#{t.day}")
    end
    t
  end
private
  @@date_util = nil
  def date_util
    @@date_util ||= Shoji::JavaLoader.import 'org.apache.poi.ss.usermodel.DateUtil'
  end
end
