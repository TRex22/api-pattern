module ApiPattern
  class Client
    include ::ApiPattern::Constants

    attr_reader :token, :base_path, :port, :content_type

    def initialize(token:, content_type:, base_path:, port: BASE_PORT)
      @token = token
      @content_type = content_type
      @base_path = base_path
      @port = port
    end

    def self.compatible_api_version
      raise NotImplementedError
    end

    # This is the version of the API docs this client was built off-of
    def self.api_version
      raise NotImplementedError
    end

    private

    def unauthorised_and_send(http_method:, path:, payload: {}, params: {})
      start_time = get_micro_second_time

      response =
        ::HTTParty.send(
          http_method.to_sym,
          construct_base_path(path, params),
          body: payload,
          headers: {
            "Content-Type": @content_type,
          },
          port: port,
          format: :json
        )

      end_time = get_micro_second_time
      construct_response_object(response, path, start_time, end_time)
    end

    def authorise_and_send(http_method:, path:, payload: {}, params: {})
      start_time = get_micro_second_time

      response =
        ::HTTParty.send(
          http_method.to_sym,
          construct_base_path(path, params),
          body: payload,
          headers: {
            "Content-Type": @content_type,
            Token: token,
          },
          port: port,
          format: :json
        )

      end_time = get_micro_second_time
      construct_response_object(response, path, start_time, end_time)
    end

    def construct_response_object(response, path, start_time, end_time)
      {
        "body" => parse_body(response, path),
        "headers" => response.headers,
        "metadata" => construct_metadata(response, start_time, end_time)
      }
    end

    def construct_metadata(response, start_time, end_time)
      total_time = end_time - start_time

      {
        "start_time" => start_time,
        "end_time" => end_time,
        "total_time" => total_time
      }
    end

    def body_is_present?(response)
      !body_is_missing?(response)
    end

    def body_is_missing?(response)
      response.body.nil? || response.body.empty?
    end

    def parse_body(response, path)
      parsed_response = JSON.parse(response.body) # Purposely not using HTTParty

      if parsed_response.dig(path.to_s)
        parsed_response.dig(path.to_s)
      else
        parsed_response
      end
    rescue JSON::ParserError => _e
      response.body
    end

    def get_micro_second_time
      (Time.now.to_f * 1_000_000).to_i
    end

    def construct_base_path(path, params)
      constructed_path = "#{base_path}/#{path}"

      if params == {}
        constructed_path
      else
        "#{constructed_path}?#{process_params(params)}"
      end
    end

    def process_params(params)
      params.keys.map { |key| "#{key}=#{params[key]}" }.join("&")
    end
  end
end
