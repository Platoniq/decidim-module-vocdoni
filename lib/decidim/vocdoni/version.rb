# frozen_string_literal: true

module Decidim
  # This holds the decidim-meetings version.
  module Vocdoni
    DECIDIM_VERSION = "0.30.0"
    DECIDIM_COMPAT_VERSION = [">= 0.30.0", "< 0.31"].freeze

    def self.version
      "4.0"
    end
  end
end
