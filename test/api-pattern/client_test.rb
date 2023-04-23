require 'minitest/autorun'
require 'minitest/focus'
require 'webmock/minitest'

require 'httparty'

require 'api-pattern/constants'
require 'api-pattern/client'

module ApiPattern
  class ExampleClient < Client
    def example_unauthorised_get
      unauthorised_and_send(
        http_method: :get,
        path: 'messages'
      )
    end

    def example_unauthorised_post(payload)
      unauthorised_and_send(
        http_method: :post,
        path: '/users',
        payload: payload
      )
    end
  end

  class TestClient < Minitest::Test
    def setup
      @client = ExampleClient.new(
        token: 'abc123',
        content_type: 'application/json',
        base_path: 'https://example.com',
        port: 443
      )
    end

    def test_unauthorised_and_send_get_request
      response = {
        body: { message: 'Success' },
        headers: { 'Content-Type' => 'application/json' },
        metadata: {
          start_time: 1577836800,
          end_time: 1577836900,
          total_time: 100
        }
      }

      stub_request(:get, 'https://example.com/messages')
        .to_return(status: 200, body: { message: 'Success' }.to_json)

      assert_equal response, @client.example_unauthorised_get
    end

    def test_unauthorised_and_send_post_request
      payload = { name: 'John Doe' }

      response = {
        body: { id: 123 },
        headers: { 'Content-Type' => 'application/json' },
        metadata: {
          start_time: 1577836800,
          end_time: 1577836900,
          total_time: 100
        }
      }

      stub_request(:post, 'https://example.com/users')
        .with(body: payload.to_json)
        .to_return(status: 201, body: { id: 123 }.to_json)

      assert_equal response, @client.example_unauthorised_post(payload)
    end
  end
end
