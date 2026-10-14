class ResumePosition
  class Invalid < StandardError; end

  def self.parse(hours, minutes, seconds)
    total = (read(hours, 0..99, :hours) * 3600) +
            (read(minutes, 0..59, :minutes) * 60) +
            read(seconds, 0..59, :seconds)
    raise Invalid, I18n.t("resume_position.positive") unless total.positive?

    total
  end

  def self.read(value, range, unit)
    text = value.to_s.strip
    return 0 if text.empty?

    number = Integer(text, 10)
    return number if range.cover?(number)

    raise Invalid, I18n.t("resume_position.range", label: unit_label(unit), min: range.first, max: range.last)
  rescue ArgumentError
    raise Invalid, I18n.t("resume_position.integer", label: unit_label(unit))
  end

  def self.unit_label(unit)
    I18n.t("resume_position.units.#{unit}")
  end

  private_class_method :read, :unit_label
end
