require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class TestClass
  extend MethodCaching::ClassMethods
  include MethodCaching::InstanceMethods
  method_caching :identifier

  def method_to_be_cleared; end

  def method_to_be_cached
    calculate(2)
  end
  cache_method :method_to_be_cached
  cache_method_clear_on :method_to_be_cleared, :method_to_be_cached

  def identifier
    "id"
  end

  def calculate(x)
    x
  end
end

class Rails
  def self.cache
    RailsCache.new
  end
end

class RailsCache
  @@cache_hash = {}
  def fetch(key, &block)
    if @@cache_hash[key]
      @@cache_hash[key]
    else
      @@cache_hash[key] = *block.call
      @@cache_hash[key]
    end
  end

  def delete(key)
    @@cache_hash[key] = nil
  end

  def clear
    @@cache_hash = {}
  end
end

describe "MethodCaching" do
  let(:test_class) { TestClass.new }
  before do
    Rails.cache.clear
  end
  describe "#cache_method" do
    context "call cached method for multiple times" do
      it "should actually call the method once" do
        test_class.should_receive(:calculate).once
        2.times { test_class.method_to_be_cached }
      end
    end
  end

  describe "#clear_cache_on" do
    it "should clear cache for method on object" do
      test_class.should_receive(:calculate).twice
      test_class.method_to_be_cached
      test_class.clear_cache_on :method_to_be_cached
      test_class.method_to_be_cached
    end
  end

  describe "#cache_method_clear_on" do
    it "should clear cache when calling clear_method" do
      test_class.should_receive(:calculate).twice
      test_class.method_to_be_cached
      test_class.method_to_be_cleared
      test_class.method_to_be_cached
    end
  end
end
