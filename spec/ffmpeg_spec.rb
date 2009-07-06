$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require 'fileutils'
require 'tmpdir'

include FileUtils

describe Scissor::FFmpeg do
  before do
#    @video = ScissorVideo(fixture('sample.flv'))
    @ffmpeg = Scissor::FFmpeg.new
    @tmp_dir = "#{Dir.tmpdir}/scissor-video-test"
    mkdir @tmp_dir
  end

  after do
    @ffmpeg.cleanup
    rm_rf @tmp_dir
  end

  it "should set command to 'ffmpeg'" do
    @ffmpeg.command.should include 'ffmpeg'
  end

  describe "#prepare" do
    it "should convert flv to avi" do
      result = @ffmpeg.prepare({:input_video => fixture('sample.flv')})
      result.to_s.should match /.*\.avi/
    end

    it "should raise error if unknwon format" do
      lambda {
        @ffmpeg.prepare({:input_video => 'unkwonformat.csv'})
      }.should raise_error(Scissor::Command::UnknownFormat)
    end
  end

  describe "#cut" do
    it "should return VideoChunk" do
      output_file = @tmp_dir + '/cut.flv'
      chunk = @ffmpeg.cut({
                            :input_video => fixture('sample.flv'),
                            :output_video => output_file,
                            :start => 1,
                            :duration => 5
                          })
      chunk.should be_an_instance_of(Scissor::VideoChunk)
      chunk.duration.should be_close(5, 0.5) #?
    end
  end
end
