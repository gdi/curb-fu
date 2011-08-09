require 'cgi'

##
# ActiveSupport look alike for to_param_pair. Very useful.
module CurbFu
  module HashExtensions
    def self.included(base)
      base.send(:include, InstanceMethods)
      #base.extend(ClassMethods)
    end
    
    module InstanceMethods
      def to_param_pair(prefix)
        collect do |k, v|
          key_prefix = prefix ? "#{prefix}[#{k}]" : k
          v.to_param_pair(key_prefix)
        end.join("&")
      end
    end
  end
  
  module ObjectExtensions
    def self.included(base)
      base.send(:include, InstanceMethods)
      #base.extend(ClassMethods)
    end
    
    module InstanceMethods
      def to_param_pair(prefix = self.class)
        value = CGI::escape(to_s)
        "#{prefix}=#{value}"
      end
    end
  end
  
  module ArrayExtensions
    def self.included(base)
      base.send(:include, InstanceMethods)
      #base.extend(ClassMethods)
    end
    
    module InstanceMethods
      def to_param_pair(prefix)
        prefix = "#{prefix}[]"
        collect { |item| "#{item.to_param_pair(prefix)}" }.join('&')
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
class String
  include CurbFu::ObjectExtensions
end
class Fixnum
  include CurbFu::ObjectExtensions
end
