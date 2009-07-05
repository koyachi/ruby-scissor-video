$:.unshift File.dirname(__FILE__) + '/../lib/'

require 'scissor'
require 'scissor-video'

def fixture(filename)
  File.dirname(__FILE__) + '/fixtures/' + filename
end
