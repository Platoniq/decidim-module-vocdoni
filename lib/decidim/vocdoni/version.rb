# frozen_string_literal: true

module Decidim
  # This holds the decidim-meetings version.
  module Vocdoni
    DECIDIM_VERSION = "0.29.1"
    DECIDIM_COMPAT_VERSION = [">= 0.29.0", "< 0.30"].freeze

    def self.version
      "3.0"
    end
  end
end
