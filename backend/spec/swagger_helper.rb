require "rails_helper"

RSpec.configure do |config|
  config.swagger_root = Rails.root.join("swagger").to_s

  config.swagger_docs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "The Flock API",
        version: "v1",
        description: "Twitter clone API documentation"
      },
      paths: {},
      servers: [
        { url: "http://localhost:3000", description: "Local development" }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT"
          }
        }
      }
    }
  }

  config.swagger_format = :yaml
end
