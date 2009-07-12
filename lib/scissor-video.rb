require 'scissor'
require 'scissor-video/float'
require 'scissor-video/command'
require 'scissor-video/command/ffmpeg.rb'
require 'scissor-video/command/mencoder.rb'
require 'scissor-video/chunk'
require 'scissor-video/video_file'

def ScissorVideo(*args)
  Scissor::VideoChunk.new(*args)
end

def Scissor(*args)
#  Scissor::Chunk.new(*args)
  if args.length == 0
    Scissor::Chunk.new(*args)
  else
    filename = args[0]
    f = Pathname.new(filename)
    ext = f.extname.sub(/^\./, '').downcase
    if Scissor::SoundFile::SUPPORTED_FORMATS.include?(ext)
      Scissor::Chunk.new(filename)
    else
      ScissorVideo(filename)
    end
  end
end

module Scissor
  @logger = Logger.new(STDOUT)
  @logger.level = Logger::INFO

  class << self
    attr_accessor :logger, :workspace
  end

  def logger
    self.class.logger
  end

  def workspace
    self.class.workspace
  end

  class << self
    def ffmpeg(*args)
      FFmpeg.new(*args)
    end

    def mencoder(*args)
      Mencoder.new(*args)
    end
  end
end

