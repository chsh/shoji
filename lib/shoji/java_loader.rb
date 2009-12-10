
class Shoji::JavaLoader
  @@jars_loaded = false
  @@jruby = nil
  @@should_be_loaded_jars = nil
  # Only keep jars paths internally.
  def self.paths=(jars)
    detect_jruby_and_keep_jars(jars) unless @@jars_loaded
  end
  def self.import(class_string)
    unless @@jars_loaded
      begin
        lazy_load_jars
      rescue => e
        raise LoadError.new(e.message)
      end
    end
    if jruby?
      eval(class_string)
    else
      Rjb::import class_string
    end
  end
  def self.jruby?; @@jruby; end
  def self.rjb?; !@@jruby; end
private
  def self.detect_jruby_and_keep_jars(jars)
    if defined? JRUBY_VERSION
      @@jruby = true
    else
      @@jruby = false
    end
    @@should_be_loaded_jars = jars
  end

  def self.lazy_load_jars
    if @@jruby
      @@should_be_loaded_jars.map do |jar|
        raise "File not found file=#{jar}" unless File.exist? jar
#        puts "JRUBY:loading jar.#{jar}"
          require jar
      end
    else
      require 'rjb'
      Rjb::load(@@should_be_loaded_jars.join(':'), [
        '-Xms64m', '-Xmx128m'
      ])
    end
    @@jars_loaded = true
  end

end
