module ApiPattern
  class Client
    include ::ApiPattern::Constants

    attr_reader :base_path, :port, :content_type, :limit

    # Other auth parameters may be removed in the future
    # For now making sure this base is compatible with all my API clients
    attr_reader :auth, :auth_type
    attr_reader :token
    attr_reader :username, :key
    attr_reader :password, :secret

    # Response instance variables
    attr_reader :login_response, :raw_cookie, :expiry

    def initialize(base_path:, content_type:, port: BASE_PORT, auth: EMPTY_AUTH, auth_type: DEFAULT_AUTH_TYPE, token: EMPTY_PARAMETER, api_token: EMPTY_PARAMETER, access_token: EMPTY_PARAMETER, username: EMPTY_PARAMETER, key: EMPTY_PARAMETER, password: EMPTY_PARAMETER, secret: EMPTY_PARAMETER, limit: EMPTY_PARAMETER)
      process_auth(auth, auth_type, token, api_token, access_token, username, key, password, secret)

      @content_type = content_type
      @base_path = base_path
      @port = port
      @limit = limit
    end

    def self.compatible_api_version
      raise NotImplementedError
    end

    # This is the version of the API docs this client was built off-of
    def self.api_version
      raise NotImplementedError
    end

    private

    def unauthorised_and_send(http_method:, path:, custom_url: nil, payload: {}, params: {}, format: :json)
      start_time = get_micro_second_time

      response = ::HTTParty.send(
        http_method.to_sym,
        construct_base_path(path, params, custom_url: custom_url),
        body: process_payload(payload),
        headers: {
          "Content-Type": @content_type,
        },
        port: port,
        format: format,
      )

      end_time = get_micro_second_time
      construct_response_object(response, path, start_time, end_time)
    end

    def authorise_and_send(http_method:, path:, custom_url: nil, payload: {}, params: {}, format: :json)
      start_time = get_micro_second_time

      send_params = {
        body: process_payload(payload),
        headers: {
          "Content-Type": @content_type
        },
        port: port,
        format: format,
      }

      response = ::HTTParty.send(
        http_method.to_sym,
        construct_base_path(path, params, custom_url: custom_url),
        **configure_auth(send_params)
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

    def construct_base_path(path, params, custom_url: nil)
      return custom_url if custom_url.present? && path.blank? && params.blank?
      return base_path if path.blank? && params.blank?

      if custom_url.present?
        constructed_path = "#{custom_url}/#{path}"
      else
        constructed_path = "#{base_path}/#{path}"
      end

      if params.blank?
        constructed_path
      else
        "#{constructed_path}?#{process_params(params)}"
      end
    end

    def process_payload(payload)
      return nil if payload.blank?

      if @content_type.to_s.downcase.include?("json")
        payload.to_json
      else
        payload
      end
    end

    def process_params(params)
      params.keys.map { |key| "#{key}=#{params[key]}" }.join("&")
    end

    def process_auth(auth, auth_type, token, api_token, access_token, username, key, password, secret)
      @auth = auth || {}
      @auth_type = auth_type

      if token.present? || api_token.present? || access_token.present?
        @auth["token"] = token || api_token || access_token

        @auth_type = "token"
        @token = token || api_token || access_token
      elsif username.present? && password.present?
        @auth["username"] = username
        @auth["password"] = password

        basic_auth(username, password)
      elsif key.present? && secret.present?
        @key = key
        @secret = secret

        basic_auth(key, secret)
      end
    end

    def basic_auth(username, password)
      @auth["username"] = username
      @auth["password"] = password

      @auth_type = "basic"
      @username = username
      @password = password
    end

    # Need to use symbols here to HTTParty named parameters
    def configure_auth(send_params)
      if @auth_type == "token"
        headers = send_params[:headers]
        headers["Token"] = @auth["token"]
        send_params[:headers] = headers
      elsif @auth_type == "basic"
        send_params[:basic_auth] = @auth # { username: "", password: "" }
      end

      # TODO: Using aliases for the sending
      # TODO: Basic auth via body
      # TODO: Separate login flow

      send_params
    end

    # https://stackoverflow.com/questions/913349/what-is-the-best-way-to-create-alias-to-attributes-in-ruby
    def alias_attr(new_attr, original)
      alias_method(new_attr, original) if method_defined? original

      new_writer = "#{new_attr}="
      original_writer = "#{original}="
      alias_method(new_writer, original_writer) if method_defined? original_writer
    end
  end
end
