# -*- coding: utf-8 -*-
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
    command.command.should be_nil
  end

  it "should set command variable" do
    command = Scissor::Command.new({:command => 'ls'})
    command.work_dir.should eql(Pathname.new(Dir.tmpdir + "/scissor-video-work-" + $$.to_s))
    command.work_dir.should be_exist
    command.command.should eql('ls')
  end

  it "should return command result by #_run_command" do
    command = Scissor::Command.new({})
    command._run_command('ls').should include('Rakefile')
  end

  it "should log command error when logger.lebel == DEBUG" do
    _logger = Scissor.logger
    _level = Scissor.logger.level

    file = 'log.log'
    Scissor.logger = Logger.new file
    Scissor.logger.level = Logger::DEBUG
    command = Scissor::Command.new({})
    lambda {
      command._run_command('ls -w')
    }.should raise_error(Scissor::Command::CommandFailed)
    f = open file
    begin
      buff = f.readlines.join('')
    ensure
      f.close
      File.unlink file
    end
    buff.should include "ls: option requires an argument -- 'w'"
    
    Scissor.logger = _logger
    Scissor.logger.level = _level
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
