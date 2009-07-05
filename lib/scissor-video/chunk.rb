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
        :overwrite => false,
        :save_workfiles => false
      }.merge(options)

      filename = Pathname.new(filename)

      if filename.exist?
        if options[:overwrite]
          filename.unlink
        else
          raise FileExists
        end
      end

      concat_files = []
      ffmpeg = FFmpeg.new

      position = 0.0
      tmpdir = ffmpeg.work_dir
      tmpfile = tmpdir + 'tmp.avi'

      begin
        @fragments.each_with_index do |fragment, index|
          fragment_filename = fragment.filename
          fragment_duration = fragment.duration

          fragment_tmpfile = tmpdir + (Digest::MD5.hexdigest(fragment_filename) + "_#{index}.avi")

          unless fragment_tmpfile.exist?
            ffmpeg.cut({
                         :input_video => fragment_filename,
                         :output_video => fragment_tmpfile,
                         :start => fragment.start,
                         :duration => fragment_duration
            })
            concat_files.push fragment_tmpfile
          end

          position += fragment_duration
        end

        Mencoder.new.concat({
                              :input_videos => concat_files,
                              :output_video => tmpfile
        })

        ffmpeg.encode({
                        :input_video => tmpfile,
                        :output_video => filename
        })
      ensure
        ffmpeg.cleanup unless options[:save_workfiles]
      end

      self.class.new(filename)
    end
  end
end
