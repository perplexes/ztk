module ZTK::DSL
  module Core
    autoload :Attributes, "ztk/dsl/core/attributes"
    autoload :Actions, "ztk/dsl/core/actions"
    autoload :Dataset, "ztk/dsl/core/dataset"
    autoload :IO, "ztk/dsl/core/io"
    autoload :Relations, "ztk/dsl/core/relations"

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::ClassMethods)

        base.send(:include, ZTK::DSL::Core::Attributes)
        base.send(:include, ZTK::DSL::Core::Actions)
        base.send(:include, ZTK::DSL::Core::Dataset)
        base.send(:include, ZTK::DSL::Core::IO)
        base.send(:include, ZTK::DSL::Core::Relations)
      end
    end

    module ClassMethods

      def cattr_accessor(*args)
        cattr_reader(*args)
        cattr_writer(*args)
      end

      def cattr_reader(*args)
        args.flatten.each do |arg|
          next if arg.is_a?(Hash)
          instance_eval %Q{
            unless defined?(@@#{arg})
              @@#{arg} = nil
            end

            def #{arg}
              @@#{arg}
            end
          }
        end
      end

      def cattr_writer(*args)
        args.flatten.each do |arg|
          next if arg.is_a?(Hash)
          instance_eval %Q{
            unless defined?(@@#{arg})
              @@#{arg} = nil
            end

            def #{arg}=(value)
              @@#{arg} = value
            end
          }
        end
      end
    end

  end
end
