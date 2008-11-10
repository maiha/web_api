module WebApi
  class WebApiError       < RuntimeError; end
  class ResponseNotFound  < WebApiError; end
  class ParameterNotFound < WebApiError; end
  class InvalidValue      < WebApiError; end
  class ValidationPassed  < WebApiError; end

  class Base
    class << self
      def default_request
        @default_request or
          raise NotImplementedError, "subclass responsibility"
      end

      def request(&block)
        @default_request = returning(Class.new(WebApi::Request)){|req| req.instance_eval(&block)}
      end
    end

    def initialize(attributes = {}, options = {})
      @request = self.class.default_request.new(attributes)
    end

    def request
      @request
    end

    def response
      @response or raise ResponseNotFound
    end

    def execute
      @response = request.execute
      parse
    end

    protected

    def parse
    end

    def scraper
    end
  end
end

