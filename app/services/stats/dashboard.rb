module Stats
  class Dashboard
    def initialize(user)
      @entries = user.entries
    end

    def total = @entries.count
    def watched_count = @entries.watched.count

    def by_status
      counts = @entries.group(:status).count
      Entry.statuses.keys.index_with { |status| counts[status] || 0 }
    end

    def by_month(months = 6)
      from = (months - 1).months.ago.beginning_of_month
      counts = @entries.watched.where(watched_at: from..)
                       .group_by { |entry| entry.watched_at.strftime("%Y-%m") }
                       .transform_values(&:size)

      (0...months).map do |offset|
        key = (from + offset.months).strftime("%Y-%m")
        [ key, counts[key] || 0 ]
      end
    end

    def by_media_type
      @entries.where.not(media_type: [ nil, "" ]).group(:media_type).count
    end

    def average_rating
      @entries.where.not(rating: nil).average(:rating)&.round(1)
    end
  end
end
