require "pry"
require "./lib/knx"
task :pry do
  begin
    Pry.start
  rescue NameError
    STDERR.puts "Pry isn't installed. Place this in the development group in your Gemfile"
  end
end

task :console => :pry
task :c => :pry
task default: :pry
