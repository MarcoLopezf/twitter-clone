module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_by_username_or_display_name(query)
      return none if query.blank?

      term = "%#{sanitize_sql_like(query)}%"
      where("username ILIKE ? OR display_name ILIKE ?", term, term)
    end
  end
end
