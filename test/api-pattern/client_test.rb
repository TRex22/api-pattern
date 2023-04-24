require "test_helper"

module ApiPattern
  class ExampleClient < Client
    # def self.compatible_api_version
    #   'v1'
    # end

    # def self.api_version
    #   'v1 2023-04-24'
    # end

    def example_unauthorised_get
      unauthorised_and_send(http_method: :get, path: "messages")
    end

    def example_unauthorised_post(payload)
      unauthorised_and_send(http_method: :post, path: "users", payload: payload)
    end
  end

  class TestClient < Minitest::Test
    def setup
      @time = Time.now

      Timecop.freeze(@time) do
        @client = ExampleClient.new(
          token: "abc123",
          content_type: "application/json",
          base_path: "https://example.com",
          port: 443
        )
      end
    end

    def test_compatible_api_version_raises_not_implemented_error
      assert_raises NotImplementedError do
        @client.class.compatible_api_version
      end
    end

    def test_api_version_raises_not_implemented_error
      assert_raises NotImplementedError do
        @client.class.api_version
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
          @client.example_unauthorised_get.with_indifferent_access
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
          @client.example_unauthorised_post(payload).with_indifferent_access
      end
    end
  end
end
