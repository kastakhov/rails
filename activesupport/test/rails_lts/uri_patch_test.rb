require 'uri'
require 'timeout'
require 'abstract_unit'
require 'active_support/rails_lts/uri_patch'

class UriPatchTest < ActiveSupport::TestCase
  test "fixes CVE-2023-28755 ReDoS" do
    vulnerable_uri = 'https://example.com/dir/' + 'a' * (100000) + '/##.jpg' # Approx. 4s without a patch

    assert_raises(URI::InvalidURIError) do
      Timeout.timeout(0.1) { URI.parse(vulnerable_uri) }
    end
  end
end
