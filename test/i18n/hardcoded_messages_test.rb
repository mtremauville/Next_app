require "test_helper"

class HardcodedMessagesTest < ActiveSupport::TestCase
  test "controllers translate their flash messages" do
    offenders = Dir[Rails.root.join("app/controllers/**/*.rb")].flat_map do |file|
      File.readlines(file).each_with_index.filter_map do |line, index|
        "#{file.sub("#{Rails.root}/", '')}:#{index + 1}" if line.match?(/(notice|alert): *"/)
      end
    end

    assert_empty offenders, "Messages en dur à traduire : #{offenders.join(', ')}"
  end
end
