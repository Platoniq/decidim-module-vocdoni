# frozen_string_literal: true

module Decidim
  module Vocdoni
    class VocdoniElectionsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "VocdoniElections"
      description "An elections component of a participatory space."

      field :elections, Decidim::Vocdoni::VocdoniElectionType.connection_type, null: true, connection: true # rubocop:disable GraphQL/FieldDescription

      field :election, Decidim::Vocdoni::VocdoniElectionType, null: true do # rubocop:disable GraphQL/FieldDescription
        argument :id, GraphQL::Types::ID, required: true # rubocop:disable GraphQL/ArgumentDescription
      end

      def elections
        VocdoniElectionsTypeHelper.base_scope(object).includes(:component)
      end

      def election(**args)
        VocdoniElectionsTypeHelper.base_scope(object).find_by(id: args[:id])
      end
    end

    module VocdoniElectionsTypeHelper
      def self.base_scope(component)
        Election.where(component:).where.not(published_at: nil)
      end
    end
  end
end
