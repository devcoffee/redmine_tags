require_dependency 'queries_helper'

module RedmineTags
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        include TagsHelper

        def column_content(column, item)
          begin
            value = column.value_object(item)
          rescue
            value = nil
          end
          if column.name == :tags && value.present? && value.kind_of?(ActiveRecord::Associations::CollectionProxy)
            value = column.value(item)
            value.collect{ |t| render_tag_link(t) }.join(RedmineTags.settings[:issues_use_colors].to_i > 0 ? ' ' : ', ').html_safe
          else
            super
          end
        end

        def csv_content(column, issue)
          if column.name == :tags && column.value_object(issue).kind_of?(ActiveRecord::Associations::CollectionProxy)
            value = column.value_object(issue).to_a
            value.collect {|v| csv_value(column, issue, v)}.compact.join(', ')
          else
            super
          end
        end
      end
    end
  end
end

base = QueriesHelper
patch = RedmineTags::Patches::QueriesHelperPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
