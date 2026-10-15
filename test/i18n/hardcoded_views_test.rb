require "test_helper"

class HardcodedViewsTest < ActiveSupport::TestCase
  test "views contain no hard-coded accented text" do
    offenders = Dir[Rails.root.join("app/views/**/*.erb")].flat_map do |file|
      relative = file.sub("#{Rails.root}/app/views/", "")

      File.readlines(file).each_with_index.filter_map do |line, index|
        next unless line.match?(/[éèêàùçôî]/)
        next if line.include?("t(") || line.include?("I18n")

        "#{relative}:#{index + 1}"
      end
    end

    assert_empty offenders, "Texte en dur à traduire : #{offenders.join(', ')}"
  end
end
