module MethodCaching
  module ClassMethods
    def method_caching(identifier_attr = :id)
      @identifier = identifier_attr.to_sym
      self.send(:include, InstanceMethods)
    end

    def cache_method(method, options = {})
      old = "_#{method}".to_sym
      alias_method old, method
      define_method method do |*args|
        Rails.cache.fetch(cache_key_name(method)) do
          send(old, *args)
        end
      end

      clear_methods = [options[:clear_on]].flatten.compact
      clear_methods.each do |clear_method|
        cache_method_clear_on(clear_method, method)
      end
    end

    def cache_method_clear_on(clear_method, cache_method)
      original_method = "_cache_method_clear_on_#{clear_method}"
      alias_method original_method, clear_method

      define_method clear_method do |*args, &blk|
        self.clear_cache_on cache_method
        send(original_method, *args, &blk)
      end
    end

    def identifier
      @identifier
    end
  end

  module InstanceMethods
    def clear_cache_on(method)
      Rails.cache.delete(cache_key_name(method))
    end

    def cache_key_name(method)
      identifier_method = self.class.send(:identifier)
      "#{self.class.to_s}_#{self.send(identifier_method)}_#{method.to_s}"
    end
  end

  module Generic
    include ::MethodCaching::InstanceMethods

    def self.included(klass)
      klass.send(:extend, ::MethodCaching::ClassMethods)
    end
  end
end

if defined?(ActiveRecord)
  ActiveRecord::Base.send(:include, MethodCaching::InstanceMethods)
  ActiveRecord::Base.send(:extend, MethodCaching::ClassMethods)
end
