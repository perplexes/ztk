module ZTK::DSL::Core

  # @author Zachary Patten <zachary AT jovelabs DOT com>
  # @api private
  module Relations
    autoload :BelongsTo, "ztk/dsl/core/relations/belongs_to"
    autoload :HasMany, "ztk/dsl/core/relations/has_many"

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::Relations::ClassMethods)
        base.send(:include, ZTK::DSL::Core::Relations::BelongsTo)
        base.send(:include, ZTK::DSL::Core::Relations::HasMany)
      end
    end

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module ClassMethods

      def add_relation(key)
        relation_key = "#{key}_relations"
        cattr_accessor relation_key
        send(relation_key) || send("#{relation_key}=", {})
      end

    end

  end
end
