# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/traceable_interface_examples"

module Decidim
  module Vocdoni
    # As there's already a GraphQL type called ElectionType (from the module decidim-elections)
    # we change the name to VodoniElectionType for the external API.
    # Note that internally there aren't any colition as Ruby has namespaces, meaning that
    # Decidim::Vocdoni::Election and Decidim::Vocdoni::Election isn't the same thing.
    describe VocdoniElectionType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:vocdoni_election, :published) }

      it_behaves_like "attachable interface"

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

      describe "streamUri" do
        let(:query) { "{ streamUri }" }

        it "returns the election's stream URI" do
          expect(response["streamUri"]).to eq(model.stream_uri)
        end
      end

      describe "startTime" do
        let(:query) { "{ startTime }" }

        it "returns the election's start time" do
          expect(Time.zone.parse(response["startTime"])).to be_within(1.second).of(model.start_time)
        end
      end

      describe "endTime" do
        let(:query) { "{ endTime }" }

        it "returns the election's end time" do
          expect(Time.zone.parse(response["endTime"])).to be_within(1.second).of(model.end_time)
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns the election's published time" do
          expect(Time.zone.parse(response["publishedAt"])).to be_within(1.second).of(model.published_at)
        end
      end

      describe "blocked" do
        let(:query) { "{ blocked }" }

        context "when the election's parameters are blocked" do
          let!(:model) { create(:vocdoni_election, :finished) }

          it "returns true" do
            expect(response["blocked"]).to be true
          end
        end

        context "when the election's parameters are not blocked" do
          let(:model) { create(:vocdoni_election) }

          it "returns false" do
            expect(response["blocked"]).to be_falsey
          end
        end
      end

      describe "autoStart" do
        let(:query) { "{ autoStart }" }

        it "returns the election's autoStart setting" do
          expect(response["autoStart"]).to be_truthy
        end
      end

      describe "interruptible" do
        let(:query) { "{ interruptible }" }

        it "returns the election's interruptible setting" do
          expect(response["interruptible"]).to be_truthy
        end
      end

      describe "dynamicCensus" do
        let(:query) { "{ dynamicCensus }" }

        it "returns the election's dynamicCensus setting" do
          expect(response["dynamicCensus"]).to be_falsey
        end
      end

      describe "secretUntilTheEnd" do
        let(:query) { "{ secretUntilTheEnd }" }

        it "returns the election's secret until the end setting" do
          expect(response["secretUntilTheEnd"]).to be_truthy
        end
      end

      describe "status" do
        let(:query) { "{ status }" }

        it "returns the status" do
          expect(response["status"]).to eq(model.status)
        end
      end

      describe "questions" do
        let!(:election2) { create(:vocdoni_election, :complete) }
        let(:query) { "{ questions { id } }" }
        let(:result) { response["questions"].map { |question| question["id"] } }
        let(:expected_result) { model.questions.map(&:id).map(&:to_s) }
        let(:unexpected_results) { [election2.questions.map(&:id).map(&:to_s)] }

        it "returns the election questions" do
          expect(result).to include(*expected_result) unless expected_result.empty?
          unexpected_results.each { |unexpected_result| expect(result).not_to include(*unexpected_result) unless unexpected_result.empty? }
        end
      end

      describe "voters" do
        let!(:election3) { create(:vocdoni_election, :complete) }
        let(:query) { "{ voters { wallet_address } }" }
        let(:result) { response["voters"].map { |voter| voter["wallet_address"] } }
        let(:expected_result) { model.voters.map(&:wallet_address).map(&:to_s) }
        let(:unexpected_results) { [election3.voters.map(&:wallet_address).map(&:to_s)] }

        it "returns the election voters" do
          expect(result).to include(*expected_result) unless expected_result.empty?
          unexpected_results.each { |unexpected_result| expect(result).not_to include(*unexpected_result) unless unexpected_result.empty? }
        end
      end
    end
  end
end
