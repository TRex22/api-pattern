require "test_helper"

# TODO: test_microsecond_response_timing

module ApiPattern
  class ExampleClient < Client
    # def self.compatible_api_version
    #   'v1'
    # end

    # def self.api_version
    #   'v1 2023-04-24'
    # end

    def example_unauthorised_get_no_path(custom_url: nil)
      unauthorised_and_send(http_method: :get, path: "", custom_url: custom_url)
    end

    def example_unauthorised_get(custom_url: nil)
      unauthorised_and_send(http_method: :get, path: "messages", custom_url: custom_url)
    end

    def example_unauthorised_post(payload)
      unauthorised_and_send(http_method: :post, path: "users", payload: payload)
    end
  end

  class ExampleTokenAuthClient < Client
    def example_authorised_get(custom_url: nil)
      authorise_and_send(http_method: :get, path: "messages", custom_url: custom_url)
    end

    def example_authorised_post(payload)
      authorise_and_send(http_method: :post, path: "users", payload: payload)
    end
  end

  class ExampleBasicAuthClient < Client
    def example_authorised_get
      authorise_and_send(http_method: :get, path: "messages")
    end

    def example_authorised_post(payload)
      authorise_and_send(http_method: :post, path: "users", payload: payload)
    end
  end

  class TestClient < Minitest::Test
    def setup
      @time = Time.now
      @token = "abc123"

      Timecop.freeze(@time) do
        @unauthed_client = ExampleClient.new(
          content_type: "application/json",
          base_path: "https://example.com",
          port: 443
        )

        @token_auth_client = ExampleTokenAuthClient.new(
          token: @token,
          content_type: "application/json",
          base_path: "https://example.com",
          port: 443
        )

        @basic_auth_client = ExampleBasicAuthClient.new(
          username: "abc123",
          password: "abc123",
          content_type: "application/json",
          base_path: "https://example.com",
          port: 443
        )
      end
    end

    def test_compatible_api_version_raises_not_implemented_error
      assert_raises NotImplementedError do
        @unauthed_client.class.compatible_api_version
      end
    end

    def test_api_version_raises_not_implemented_error
      assert_raises NotImplementedError do
        @unauthed_client.class.api_version
      end
    end

    def test_authorised_and_send_get_request_with_basic_auth
      Timecop.freeze(@time) do
        response = {
          body: {
            message: "Success"
          },
          headers: {
            "Content-Type" => ["application/json"],
          },
          metadata: {
            start_time: (@time.to_f * 1_000_000).to_i,
            end_time: (@time.to_f * 1_000_000).to_i,
            total_time: 0
          }
        }

        stub_request(:get, "https://example.com/messages").with(
            headers: {
              "Content-Type" => "application/json",
              "Authorization"=>"Basic Og=="
            },
          ).to_return(
            status: 200,
            body: { message: "Success" }.to_json,
            headers: {
              "Content-Type" => "application/json",
            }
        )

        assert_equal response.with_indifferent_access,
          @basic_auth_client.example_authorised_get.with_indifferent_access
      end
    end

    def test_authorised_and_send_post_request_with_basic_auth
      Timecop.freeze(@time) do
        payload = { name: "John Doe" }

        response = {
          body: {
            id: 123
          },
          headers: {
            "Content-Type" => ["application/json"],
          },
          metadata: {
            start_time: (@time.to_f * 1_000_000).to_i,
            end_time: (@time.to_f * 1_000_000).to_i,
            total_time: 0
          }
        }

        stub_request(:post, "https://example.com/users").with(
          body: payload.to_json,
          headers: {
            "Content-Type" => "application/json",
            "Authorization"=>"Basic Og=="
          },
        ).to_return(
          status: 201,
          body: { id: 123 }.to_json,
          headers: {
            "Content-Type" => "application/json"
          },
        )

        assert_equal response.with_indifferent_access,
          @basic_auth_client.example_authorised_post(payload).with_indifferent_access
      end
    end

    def test_authorised_and_send_get_request_with_token_with_custom_url
      Timecop.freeze(@time) do
        response = {
          body: {
            message: "Success"
          },
          headers: {
            "Content-Type" => ["application/json"],
          },
          metadata: {
            start_time: (@time.to_f * 1_000_000).to_i,
            end_time: (@time.to_f * 1_000_000).to_i,
            total_time: 0
          }
        }

        stub_request(:get, "https://new.example.com/messages").with(
            headers: {
              "Content-Type" => "application/json",
              Token: @token,
            },
          ).to_return(
            status: 200,
            body: { message: "Success" }.to_json,
            headers: {
              "Content-Type" => "application/json",
            }
        )

        assert_equal response.with_indifferent_access,
          @token_auth_client
            .example_authorised_get(custom_url: "https://new.example.com")
            .with_indifferent_access
      end
    end

    def test_authorised_and_send_get_request_with_token
      Timecop.freeze(@time) do
        response = {
          body: {
            message: "Success"
          },
          headers: {
            "Content-Type" => ["application/json"],
          },
          metadata: {
            start_time: (@time.to_f * 1_000_000).to_i,
            end_time: (@time.to_f * 1_000_000).to_i,
            total_time: 0
          }
        }

        stub_request(:get, "https://example.com/messages").with(
            headers: {
              "Content-Type" => "application/json",
              Token: @token,
            },
          ).to_return(
            status: 200,
            body: { message: "Success" }.to_json,
            headers: {
              "Content-Type" => "application/json",
            }
        )

        assert_equal response.with_indifferent_access,
          @token_auth_client.example_authorised_get.with_indifferent_access
      end
    end

    def test_authorised_and_send_post_request_with_token
      Timecop.freeze(@time) do
        payload = { name: "John Doe" }

        response = {
          body: {
            id: 123
          },
          headers: {
            "Content-Type" => ["application/json"],
          },
          metadata: {
            start_time: (@time.to_f * 1_000_000).to_i,
            end_time: (@time.to_f * 1_000_000).to_i,
            total_time: 0
          }
        }

        stub_request(:post, "https://example.com/users").with(
          body: payload.to_json,
          headers: {
            "Content-Type" => "application/json",
            Token: @token,
          },
        ).to_return(
          status: 201,
          body: { id: 123 }.to_json,
          headers: {
            "Content-Type" => "application/json"
          },
        )

        assert_equal response.with_indifferent_access,
          @token_auth_client.example_authorised_post(payload).with_indifferent_access
      end
    end

    def test_unauthorised_and_send_get_request_with_custom_url_wont_scramble_parameters
      Timecop.freeze(@time) do
        response = {
          body: {
            message: "Success"
          },
          headers: {
            "Content-Type" => ["application/json"]
          },
          metadata: {
            start_time: (@time.to_f * 1_000_000).to_i,
            end_time: (@time.to_f * 1_000_000).to_i,
            total_time: 0
          }
        }

        stub_request(:get, "https://new.example.com/export?usp=sharing&format=csv").to_return(
          status: 200,
          body: { message: "Success" }.to_json,
          headers: {
            "Content-Type" => "application/json"
          }
        )

        assert_equal response.with_indifferent_access,
          @unauthed_client
            .example_unauthorised_get_no_path(custom_url: "https://new.example.com/export?usp=sharing&format=csv")
            .with_indifferent_access
      end
    end

    def test_unauthorised_and_send_get_request_with_custom_url
      Timecop.freeze(@time) do
        response = {
          body: {
            message: "Success"
          },
          headers: {
            "Content-Type" => ["application/json"]
          },
          metadata: {
            start_time: (@time.to_f * 1_000_000).to_i,
            end_time: (@time.to_f * 1_000_000).to_i,
            total_time: 0
          }
        }

        stub_request(:get, "https://new.example.com/messages").to_return(
          status: 200,
          body: { message: "Success" }.to_json,
          headers: {
            "Content-Type" => "application/json"
          }
        )

        assert_equal response.with_indifferent_access,
          @unauthed_client
            .example_unauthorised_get(custom_url: "https://new.example.com")
            .with_indifferent_access
      end
    end

    def test_unauthorised_and_send_get_request
      Timecop.freeze(@time) do
        response = {
          body: {
            message: "Success"
          },
          headers: {
            "Content-Type" => ["application/json"]
          },
          metadata: {
            start_time: (@time.to_f * 1_000_000).to_i,
            end_time: (@time.to_f * 1_000_000).to_i,
            total_time: 0
          }
        }

        stub_request(:get, "https://example.com/messages").to_return(
          status: 200,
          body: { message: "Success" }.to_json,
          headers: {
            "Content-Type" => "application/json"
          }
        )

        assert_equal response.with_indifferent_access,
          @unauthed_client.example_unauthorised_get.with_indifferent_access
      end
    end

    def test_unauthorised_and_send_post_request
      Timecop.freeze(@time) do
        payload = { name: "John Doe" }

        response = {
          body: {
            id: 123
          },
          headers: {
            "Content-Type" => ["application/json"]
          },
          metadata: {
            start_time: (@time.to_f * 1_000_000).to_i,
            end_time: (@time.to_f * 1_000_000).to_i,
            total_time: 0
          }
        }

        stub_request(:post, "https://example.com/users").with(
          body: payload.to_json,
          headers: {
            "Content-Type" => "application/json"
          },
        ).to_return(
          status: 201,
          body: { id: 123 }.to_json,
          headers: {
            "Content-Type" => "application/json"
          },
        )

        assert_equal response.with_indifferent_access,
          @unauthed_client.example_unauthorised_post(payload).with_indifferent_access
      end
    end
  end
end
