# -*- coding: utf-8 -*-
require 'open4'
require 'logger'

module Scissor
  class Command
    attr_accessor :work_dir, :command

    class Error < StandardError; end
    class CommandFailed < Error; end

    def initialize(args)
      @command = args[:command]
      @work_dir = args[:work_dir] || Dir.tmpdir + "/scissor-video-work-" + $$.to_s
      @work_dir = Pathname.new(@work_dir)
      @work_dir.mkpath
    end

    def _run_command(cmd, force = false)
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

    def _run_hash(option, force = false)
      cmd = [@command, option.keys.map {|k| "#{k} #{option[k]}"}].flatten.join(' ')
      _run_command(cmd, force)
    end

    # パラメタ指定順番意識するものもあるので
    def _run_str(option_str, force = false)
      _run_command([@command, option_str].join(' '), force)
    end

    def run(option, force = false)
      if option.class == Hash
        _run_hash option, force
      else
        _run_str option, force
      end
    end

    def which(command)
      _run_command("which #{command}").chomp
    end
  end
end
