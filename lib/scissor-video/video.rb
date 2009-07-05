# -*- coding: utf-8 -*-
require 'digest/md5'

module Scissor
  class Chunk
    def initialize(filename = nil)
      @fragments = []

      if filename
        @fragments << Fragment.new(
          filename,
          0,
          VideoFile.new(filename).length)
      end
    end

    def to_file(filename, options = {})
      filename = Pathname.new(filename)

      if @fragments.empty?
        raise EmptyFragment
      end

      options = {
        :overwrite => false
      }.merge(options)

      filename = Pathname.new(filename)

      if filename.exist?
        if options[:overwrite]
          filename.unlink
        else
          raise FileExists
        end
      end

      position = 0.0
      tmpdir = Pathname.new('/tmp/scissor-' + $$.to_s)
      tmpdir.mkpath
      tmpfile = tmpdir + 'tmp.avi'

      concat_files = []
      ffmpeg = FFmpeg.new
      begin
        @fragments.each_with_index do |fragment, index|
          fragment_filename = fragment.filename
          fragment_duration = fragment.duration

          fragment_tmpfile = tmpdir + (Digest::MD5.hexdigest(fragment_filename) + "_#{index}.avi")

          unless fragment_tmpfile.exist?
            ffmpeg.cut({
                         :input_video => fragment_filename,
                         :output_video => fragment_tmpfile,
                         # 精度。。。
                         :start => fragment.start.to_i,
                         :duration => fragment_duration.to_i
            })
            concat_files.push fragment_tmpfile
          end

          position += fragment_duration
        end

        Mencoder.new.concat({
                              :input_videos => concat_files,
                              :output_video => tmpfile
        })

#        File.rename(tmpfile, filename)
        ffmpeg.encode({
                        :input_video => tmpfile,
                        :output_video => filename
        })
      ensure
        tmpdir.rmtree
      end

      self.class.new(filename)
    end
  end
end
