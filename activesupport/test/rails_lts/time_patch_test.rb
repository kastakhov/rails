require 'abstract_unit'

class TimePatchTest < ActiveSupport::TestCase
  test 'patched Time.rfc2822 parses a rfc 2822 date' do
    assert_equal Time.utc(2023, 1, 1, 12, 10, 20), Time.rfc2822('01 Jan 2023 12:10:20 UTC')
    assert_equal Time.utc(2023, 1, 1, 12, 10, 20), Time.rfc822('01 Jan 2023 12:10:20 UTC')
  end

  test 'Time.rfc2822 is fixed against CVE-2023-28756' do
    malicious_input = "01 Jan 2023 12:12#{' ' * 10_000}~GMT"
    t = Time.now
    Time.rfc2822(malicious_input) rescue ArgumentError
    Time.rfc822(malicious_input) rescue ArgumentError
    assert Time.now - t < 0.1, 'regexp took too long'
  end

  test 'patch is valid' do
    # we test this explicity, since the require in active_support.rb ignores errors
    require 'active_support/rails_lts/time_patch'
  end
end

