require "test_helper"

class LocaleFilesTest < ActiveSupport::TestCase
  def flatten(hash, prefix = nil)
    hash.flat_map do |key, value|
      path = [ prefix, key ].compact.join(".")
      value.is_a?(Hash) ? flatten(value, path) : [ path ]
    end
  end

  def keys_for(locale)
    files = Dir[Rails.root.join("config/locales/*.yml")].reject { |file| File.basename(file).start_with?("devise.") }
    tree = files.filter_map { |file| YAML.load_file(file)[locale.to_s] }.reduce({}) { |merged, part| merged.deep_merge(part) }

    flatten(tree)
  end

  test "French and English define the same keys" do
    assert_equal keys_for(:fr).sort, keys_for(:en).sort
  end
end
