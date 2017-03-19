require 'active_record/relation/predicate_builder'
require 'active_record/relation/predicate_builder/array_handler'

require 'active_support/concern'

module ActiveRecord
  class PredicateBuilder
    module ArrayHandlerPatch
      def call(attribute, value)
        column = case attribute.try(:relation)
                 when Arel::Nodes::TableAlias, NilClass
                 else
                   cache = ActiveRecord::Base.connection.schema_cache
                   exists_method_name = ::ActiveRecord::VERSION::MAJOR >= 5 ? :data_source_exists? : :table_exists?
                   if cache.public_send(exists_method_name, attribute.relation.name)
                     cache.columns(attribute.relation.name).detect{ |col| col.name.to_s == attribute.name.to_s }
                   end
                 end
        if column && column.respond_to?(:array) && column.array
          attribute.eq(value)
        else
          super(attribute, value)
        end
      end

      module ClassMethods

      end
    end
  end
end

ActiveRecord::PredicateBuilder::ArrayHandler.prepend ActiveRecord::PredicateBuilder::ArrayHandlerPatch
