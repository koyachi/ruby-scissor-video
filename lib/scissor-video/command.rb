# -*- coding: utf-8 -*-
require 'open4'
require 'logger'

module Scissor
  module Command
    def run_command(cmd, force = false)
      Scissor.logger.debug("run_command: #{cmd}")

      result = ''
      status = Open4.popen4(cmd) do |pid, stdin, stdout, stderr|
        err = stderr.read
        Scissor.logger.debug(err)
        result = stdout.read
        if force && err
          result = err
        end
      end

      if status.exitstatus != 0 && !force
        raise CommandFailed.new(cmd)
      end

      return result
    end

    @command
    def _run(option, force = false)
      cmd = [@command, option.keys.map {|k| "#{k} #{option[k]}"}].flatten.join(' ')
      run_command(cmd, force)
    end

    # パラメタ指定順番意識するものもあるので
    def run(option_str, force = false)
      run_command([@command, option_str].join(' '), force)
    end

    def which(command)
      run_command("which #{command}")
    end
  end

  class FFmpeg
    include Command

    def initialize(path = which('ffmpeg'), work_dir = Dir.tmpdir + "/scissor-video-ffmpeg-work")
      @command = path.chomp
      @work_dir = Pathname.new(work_dir)
      @work_dir.mkpath
    end

    # sec
    def get_duration(video)
      result = run("-i #{video}", true)
      duration = 0
      if result.match(/.*?Duration: (\d{2}):(\d{2}):(\d{2}).(\d{2}), start: .*?, bitrate: .*/m)
        duration = $1.to_i * 60 * 60 +
          $2.to_i * 60 +
          $3.to_i +
          ($4.to_i / 1000.0).to_f
      end
      duration
    end

    def cut(args)
      input_video = prepare args
      run(["-i #{input_video}",
           "-ss #{args[:start]}",
           "-t #{args[:duration]}",
           "#{args[:output_video]}"].join(' '))
    end

    def prepare(args)
      # flv2avi
      tmpfile = Pathname.new(args[:input_video])
      if (%w[flv].include? tmpfile.extname.sub(/^\./, '').downcase)
        tmpfile = @work_dir + (tmpfile.basename.to_s.split('.')[0] + '.avi')
        unless tmpfile.exist?
          run(["-i #{args[:input_video]}",
               tmpfile
              ].join(' '))
        end
        tmpfile
      else
        args[:input_video]
      end
    end

    def encode(args)
      run(["-i #{args[:input_video]}",
           "-vcodec #{args[:vcodec] || 'msmpeg4v2'}",
           "-acodec #{args[:acodec] || 'mp2'}",
           "#{args[:output_video]}"].join(' '))
    end
  end

  class Mencoder
    include Command

    def initialize(path = which('mencoder'))
      @command = path.chomp
    end

    def concat(args)
      run(["#{args[:input_videos].join(' ')}",
           "-o #{args[:output_video]}",
           "-oac copy",
           "-ovc copy"
      ].join(' '))
    end
  end
end
