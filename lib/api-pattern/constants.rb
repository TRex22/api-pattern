module ApiPattern
  module Constants
    BASE_PORT = 80

    DEFAULT_AUTH_TYPE = "basic"
    EMPTY_AUTH = {}
    EMPTY_PARAMETER = nil

    AUTH_TYPES = {
      none: 0,
      basic: 1,
      token: 2,
      oauth: 3,
    }
  end
end
