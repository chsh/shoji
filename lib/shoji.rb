
require 'shoji_main'
require 'shoji/java_loader'
files = Dir.glob("#{File.dirname(__FILE__)}/../javalib/**/*.jar")
puts files.inspect
Shoji::JavaLoader.paths = files


