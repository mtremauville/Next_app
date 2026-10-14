class ResumePosition
  class Invalid < StandardError; end

  def self.parse(hours, minutes, seconds)
    total = (read(hours, 0..99, "heures") * 3600) +
            (read(minutes, 0..59, "minutes") * 60) +
            read(seconds, 0..59, "secondes")
    raise Invalid, "Saisis une position supérieure à 0." unless total.positive?

    total
  end

  def self.read(value, range, label)
    text = value.to_s.strip
    return 0 if text.empty?

    number = Integer(text, 10)
    raise Invalid, "Les #{label} doivent être comprises entre #{range.first} et #{range.last}." unless range.cover?(number)

    number
  rescue ArgumentError
    raise Invalid, "Les #{label} doivent être un nombre entier."
  end
  private_class_method :read
end
