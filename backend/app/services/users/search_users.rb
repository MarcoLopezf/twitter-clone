module Users
  class SearchUsers
    def initialize(query)
      @query = query
    end

    def call
      User.search_by_username_or_display_name(@query)
    end
  end
end
