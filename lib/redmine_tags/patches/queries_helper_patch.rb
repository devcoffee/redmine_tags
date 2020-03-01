module RedmineTags
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        include TagsHelper

        def column_content(column, item)
          if column.name == :tags
            column.value(item).collect{ |t| render_tag_link(t) }
              .join(RedmineTags.settings[:issues_use_colors].to_i > 0 ? ' ' : ', ').html_safe
          else
            super
          end
        end

        def csv_content(column, issue)
          value = column.value_object(issue)
          if column.name == :tags
            value.collect {|v| csv_value(column, issue, v)}.compact.join(', ').html_safe
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
