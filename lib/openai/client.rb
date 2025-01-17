module OpenAI
  class Client
    def initialize(access_token: nil, organization_id: nil, uri_base: nil, request_timeout: nil, api_type: nil)
      OpenAI.configuration.access_token = access_token if access_token
      OpenAI.configuration.organization_id = organization_id if organization_id
      OpenAI.configuration.uri_base = uri_base if uri_base
      OpenAI.configuration.request_timeout = request_timeout if request_timeout
      OpenAI.configuration.api_type = api_type if api_type
    end

    def chat(parameters: {})
      OpenAI::Client.json_post(path: "/chat/completions", parameters: parameters)
    end

    def completions(parameters: {})
      OpenAI::Client.json_post(path: "/completions", parameters: parameters)
    end

    def edits(parameters: {})
      OpenAI::Client.json_post(path: "/edits", parameters: parameters)
    end

    def embeddings(parameters: {})
      OpenAI::Client.json_post(path: "/embeddings", parameters: parameters)
    end

    def files
      @files ||= OpenAI::Files.new
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes.new
    end

    def images
      @images ||= OpenAI::Images.new
    end

    def models
      @models ||= OpenAI::Models.new
    end

    def moderations(parameters: {})
      OpenAI::Client.json_post(path: "/moderations", parameters: parameters)
    end

    def transcribe(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/transcriptions", parameters: parameters)
    end

    def translate(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/translations", parameters: parameters)
    end

    def self.get(path:)
      HTTParty.get(
        uri(path: path),
        headers: headers,
        timeout: request_timeout
      )
    end

    def self.json_post(path:, parameters:)
      HTTParty.post(
        uri(path: path),
        headers: headers,
        body: parameters&.to_json,
        timeout: request_timeout
      )
    end

    def self.multipart_post(path:, parameters: nil)
      HTTParty.post(
        uri(path: path),
        headers: headers.merge({ "Content-Type" => "multipart/form-data" }),
        body: parameters,
        timeout: request_timeout
      )
    end

    def self.delete(path:)
      HTTParty.delete(
        uri(path: path),
        headers: headers,
        timeout: request_timeout
      )
    end

    private_class_method def self.uri(path:)
      if OpenAI.configuration.api_type && OpenAI.configuration.api_type == 'azure'
        OpenAI.configuration.uri_base + path + '?api-version=2022-12-01'
      else
        OpenAI.configuration.uri_base + OpenAI.configuration.api_version + path
      end
    end

    private_class_method def self.headers
      if OpenAI.configuration.api_type && OpenAI.configuration.api_type == 'azure'
        {
          "Content-Type" => "application/json",
          "api-key" => OpenAI.configuration.access_token
        }
      else
        {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{OpenAI.configuration.access_token}",
          "OpenAI-Organization" => OpenAI.configuration.organization_id
        }
      end
    end

    private_class_method def self.request_timeout
      OpenAI.configuration.request_timeout
    end
  end
end
