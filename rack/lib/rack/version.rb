# frozen_string_literal: true

module Rack
  RELEASE = "1.4.7.19"

  # Return the Rack release as a dotted string.
  def self.release
    RELEASE
  end
end
