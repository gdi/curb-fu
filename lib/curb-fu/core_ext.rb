require 'cgi'

##
# ActiveSupport look alike for to_param. Very useful.
module CurbFu
  module HashExtensions
    def self.included(base)
      base.send(:include, InstanceMethods) unless base.methods.include?(:to_param)
      #base.extend(ClassMethods)
    end
    
    module InstanceMethods
      def to_param(prefix)
        collect do |k, v|
          key_prefix = prefix ? "#{prefix}[#{k}]" : k
          v.to_param(key_prefix)
        end.join("&")
      end
    end
  end
  
  module ObjectExtensions
    def self.included(base)
      base.send(:include, InstanceMethods) unless base.methods.include?(:to_param)
      #base.extend(ClassMethods)
    end
    
    module InstanceMethods
      def to_param(prefix)
        value = CGI::escape(to_s)
        "#{prefix}=#{value}"
      end
    end
  end
  
  module ArrayExtensions
    def self.included(base)
      base.send(:include, InstanceMethods) unless base.methods.include?(:to_param)
      #base.extend(ClassMethods)
    end
    
    module InstanceMethods
      def to_param(prefix)
        prefix = "#{prefix}[]"
        collect { |item| "#{item.to_param(prefix)}" }.join('&')
      end
    end
  end
end

class Hash
  include CurbFu::HashExtensions
end
class Array
  include CurbFu::ArrayExtensions
end
class Object
  include CurbFu::ObjectExtensions
end
