# frozen_string_literal: true

# Runs one generation. Rate limits and connection errors are retried with backoff; when the retries run out the
# generation fails as :unavailable so the editor stops waiting. `client` is the seam tests use to inject the fake.
class GenerateThemeJob < ApplicationJob
  queue_as :generation

  class_attribute :client, instance_writer: false, default: nil

  retry_on Generations::Transient, wait: :polynomially_longer, attempts: 5 do |job, _error|
    generation = Generation.find_by(id: job.arguments.first)
    Generations::Operation::Fail.new.call(model: generation, code: :unavailable) if generation
  end
  discard_on ActiveRecord::RecordNotFound

  def perform(generation_id)
    generation = Generation.find(generation_id)
    Generations::Operation::Complete.new(client: self.class.client || Generations::Service::Client.new).call(model: generation)
  end
end
