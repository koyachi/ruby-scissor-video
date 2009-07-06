module Scissor
  class FFmpeg < Command
    def initialize(command = which('ffmpeg'), work_dir = nil)
      super(:command => command,
            :work_dir => work_dir
            )
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
        raise UnknownFormat
      end
    end

    def cut(args)
      input_video = prepare args
      run(["-i #{input_video}",
           "-ss #{args[:start].to_f.to_ffmpegtime}",
           "-t #{args[:duration].to_f.to_ffmpegtime}",
           "#{args[:output_video]}"].join(' '))
      ScissorVideo(args[:output_video])
    end

    def encode(args)
      run(["-i #{args[:input_video]}",
           "-vcodec #{args[:vcodec] || 'msmpeg4v2'}",
           "-acodec #{args[:acodec] || 'mp2'}",
           "#{args[:output_video]}"].join(' '))
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

    def strip_audio(video)
      # return Scissor::Chunk(Audio)
      output_audio = video.sub(/^(.*)\..*?$/, '\1.mp3')
      run(["-i #{video}",
                  "#{output_audio}"])
      Scissor::Chunk(output_audio)
    end
  end
end
