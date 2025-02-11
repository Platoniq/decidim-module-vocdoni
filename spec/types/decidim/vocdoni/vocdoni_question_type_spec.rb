# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/traceable_interface_examples"

module Decidim
  module Vocdoni
    describe VocdoniQuestionType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:vocdoni_question) }

      it_behaves_like "traceable interface" do
        let(:author) { create(:user, :admin, organization: model.component.organization) }
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the election weight" do
          expect(response["weight"]).to eq(model.weight)
        end
      end

      describe "answers" do
        let!(:question2) { create(:vocdoni_question, :complete) }
        let(:query) { "{ answers { id } }" }
        let(:result) { response["answers"].map { |question| question["id"] } }
        let(:expected_result) { model.answers.map(&:id).map(&:to_s) }
        let(:unexpected_results) { [question2.answers.map(&:id).map(&:to_s)] }

        it "returns the question answers" do
          expect(result).to include(*expected_result) unless expected_result.empty?
          unexpected_results.each { |unexpected_result| expect(result).not_to include(*unexpected_result) unless unexpected_result.empty? }
        end
      end
    end
  end
end
