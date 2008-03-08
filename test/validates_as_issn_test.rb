require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../../config/boot'
  require 'active_record'
  require 'validates_as_issn'
rescue LoadError
  require 'rubygems'
  gem 'activerecord'
  require 'active_record'
  require File.dirname(__FILE__) + '/../lib/validates_as_issn'
end

class TestRecord < ActiveRecord::Base
  def self.columns; []; end
  attr_accessor :issn
  validates_as_issn :issn
end

class ValidatesAsIssnTest < Test::Unit::TestCase
  # Check that valid issns are validated as such.
  def test_should_validate
    issns = IO.readlines(File.dirname(__FILE__) + '/../data/valid.txt')

    issns.each do |issn|
      issn.chomp!
      assert TestRecord.new(:issn => issn).valid?, "#{issn} should be valid."
      assert TestRecord.new(:issn => issn.downcase).valid?, "#{issn.downcase} should be valid."
      assert TestRecord.new(:issn => issn.gsub('[^0-9X]', '')).valid?, "#{issn.gsub('[^0-9X]', '')} should be valid."
      assert TestRecord.new(:issn => issn.downcase.gsub('[^0-9X]', '')).valid?, "#{issn.downcase.gsub('[^0-9X]', '')} should be valid."
    end
  end

  # Check that invalid issns are validated as such.
  def test_should_not_validate
    issns = IO.readlines(File.dirname(__FILE__) + '/../data/invalid.txt')

    issns.each do |issn|
      issn.chomp!
      assert !TestRecord.new(:issn => issn).valid?, "#{issn} should be valid."
      assert !TestRecord.new(:issn => issn.downcase).valid?, "#{issn.downcase} should be invalid."
      assert !TestRecord.new(:issn => issn.gsub('[^0-9X]', '')).valid?, "#{issn.gsub('[^0-9X]', '')} should be invalid."
      assert !TestRecord.new(:issn => issn.downcase.gsub('[^0-9X]', '')).valid?, "#{issn.downcase.gsub('[^0-9X]', '')} should be invalid."
    end
  end
end
