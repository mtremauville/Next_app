require "test_helper"

class LocaleFilesTest < ActiveSupport::TestCase
  def flatten(hash, prefix = nil)
    hash.flat_map do |key, value|
      path = [ prefix, key ].compact.join(".")
      value.is_a?(Hash) ? flatten(value, path) : [ path ]
    end
  end

  def keys_for(locale)
    flatten(YAML.load_file(Rails.root.join("config/locales/#{locale}.yml")).fetch(locale.to_s))
  end

  test "French and English define the same keys" do
    assert_equal keys_for(:fr).sort, keys_for(:en).sort
  end
end
