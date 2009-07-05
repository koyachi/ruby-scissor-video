require 'scissor'
require 'scissor-video/float'
require 'scissor-video/command'
require 'scissor-video/video'
require 'scissor-video/video_file'

module Scissor
  @logger = Logger.new(STDOUT)
  @logger.level = Logger::INFO

  class << self
    attr_accessor :logger
  end

  def logger
    self.class.logger
  end
end

