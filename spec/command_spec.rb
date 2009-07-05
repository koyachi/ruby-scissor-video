$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require 'fileutils'
require 'tmpdir'

include FileUtils

describe Scissor::Command do
  before do
  end

  after do
  end

  it "should make work_dir" do
    command = Scissor::Command.new({})
    command.work_dir.should eql(Pathname.new(Dir.tmpdir + "/scissor-video-work-" + $$.to_s))
    command.work_dir.should be_exist
  end

  it "should return command result by #_run_command" do
    command = Scissor::Command.new({})
    command._run_command('ls').should include('Rakefile')
  end

  it "should return command result by #_run_hash" do
    command = Scissor::Command.new({:command => 'date'})
    command._run_hash({'-d' => '1980/06/01'}).should include('1980')
  end

  it "should return command result by #_run_str" do
    command = Scissor::Command.new({:command => 'date'})
    command._run_str('-d 1980/06/01').should include('1980')
  end

  it "shoud return commnad result by #run" do
    command_hash = Scissor::Command.new({:command => 'date'})
    command_hash.run({'-d' => '1980/06/01'}).should include('1980')
    
    command_str = Scissor::Command.new({:command => 'date'})
    command_str.run('-d 1980/06/01').should include('1980')
  end

  it "should return command path by #which" do
    command = Scissor::Command.new({})
    command.which('ls').should include('/bin/ls')
  end
end
