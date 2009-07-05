# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{scissor-video}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["koyachi"]
  s.autorequire = %q{}
  s.date = %q{2009-07-05}
  s.description = %q{utility to chop video files}
  s.email = %q{rtk2106@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "ChangeLog"]
  s.files = ["README.rdoc", "ChangeLog", "Rakefile", "lib/scissor-video", "lib/scissor-video/video.rb", "lib/scissor-video/command.rb~", "lib/scissor-video/command.rb", "lib/scissor-video/video_file.rb", "lib/scissor-video/video.rb~", "lib/scissor-video/video_file.rb~", "lib/scissor-video.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://scissorvideo.rubyforge.org}
  s.rdoc_options = ["--title", "scissor-video documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README.rdoc", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{scissorvideo}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{utility to chop video files}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<scissor>, [">= 0"])
      s.add_runtime_dependency(%q<open4>, [">= 0"])
    else
      s.add_dependency(%q<scissor>, [">= 0"])
      s.add_dependency(%q<open4>, [">= 0"])
    end
  else
    s.add_dependency(%q<scissor>, [">= 0"])
    s.add_dependency(%q<open4>, [">= 0"])
  end
end
