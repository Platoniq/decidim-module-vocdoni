# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"
require "bullet"

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.profile_examples = 10
  config.default_formatter = "doc" if config.files_to_run.one?

  Rails.application.config.after_initialize do
    if Bullet.enable?
      Bullet.add_safelist(type: :counter_cache, class_name: "Decidim::Vocdoni::Answer", association: :versions)
      Bullet.add_safelist(type: :counter_cache, class_name: "Decidim::Vocdoni::Question", association: :versions)
      Bullet.add_safelist(type: :counter_cache, class_name: "Decidim::Vocdoni::Question", association: :answers)
    end
  end
end
