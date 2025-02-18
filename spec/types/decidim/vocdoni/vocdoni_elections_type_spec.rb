# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Vocdoni
    describe VocdoniElectionsType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:vocdoni_component) }

      it_behaves_like "a component query type"

      describe "elections" do
        let!(:component_vocdoni) { create_list(:vocdoni_election, 2, :published, component: model) }
        let!(:component_vocdoni_hidden) { create_list(:vocdoni_election, 2, component: model) }
        let!(:other_elections) { create_list(:vocdoni_election, 2) }

        let(:query) { "{ elections { edges { node { id } } } }" }
        let(:result) { response["elections"]["edges"].map { |edge| edge["node"]["id"] } }
        let(:expected_result) { component_vocdoni.map(&:id).map(&:to_s) }
        let(:unexpected_results) do
          [
            component_vocdoni_hidden.map(&:id).map(&:to_s),
            other_elections.map(&:id).map(&:to_s)
          ]
        end

        it "returns the elections" do
          expect(result).to include(*expected_result) unless expected_result.empty?
          unexpected_results.each { |unexpected_result| expect(result).not_to include(*unexpected_result) unless unexpected_result.empty? }
        end
      end

      describe "election" do
        let(:query) { "query VocdoniElection($id: ID!){ election(id: $id) { id } }" }
        let(:variables) { { id: election.id.to_s } }

        context "when the election belongs to the component" do
          let!(:election) { create(:vocdoni_election, :published, component: model) }

          it "finds the election" do
            expect(response["election"]["id"]).to eq(election.id.to_s)
          end
        end

        context "when the election doesn't belong to the component" do
          let!(:election) { create(:vocdoni_election) }

          it "returns null" do
            expect(response["election"]).to be_nil
          end
        end

        context "when the election belongs to the component and its publication time is nil" do
          let!(:election) { create(:vocdoni_election, component: model) }

          it "returns null" do
            expect(response["election"]).to be_nil
          end
        end
      end
    end
  end
end
