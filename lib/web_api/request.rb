WebApi::Base  # load base for exception classes

module WebApi
  class Request
    Parameter = Struct.new(:name, :value, :options)
    class Parameter
      class << self
        def normalize_name(name)
          name.to_s.underscore
        end
      end

      def initialize(*)
        super
        @assertions = []
        assert_valid_options
      end

      def normalized_name
        @normalized_name ||= self.class.normalize_name(name)
      end

      def default
        options[:default]
      end

      def assert_valid_options_in
        case options[:in]
        when NilClass
        when Array, Range
          @assertions << proc{|value|
            raise WebApi::ValidationPassed if value.blank? && options[:allow_nil]
            raise WebApi::InvalidValue, "#{name} can't accept `#{value}'" unless options[:in].include?(value)
            raise WebApi::ValidationPassed
          }
        else
          raise ArgumentError, ":in option must be an Array or a Range. but got `#{options[:in].class}'"
        end
      end

      def assert_valid_options_optional
        case options[:optional]
        when NilClass, FalseClass
          @assertions << proc{|value| raise InvalidValue, "#{name} can't be blank" if value.blank?}
        end
      end

      def assert_valid_options
        assert_valid_options_in
        assert_valid_options_optional
      end

      def validate
        @assertions.each{|assert| assert.call(value)}
      rescue WebApi::ValidationPassed
      end

      def query_string
        "%s=%s" % [name, CGI.escape(NKF::nkf('-Ws -m0', value.to_s))]
      end
    end

    class << self
      def parameter(name, options = {})
        klass = options[:class] || Parameter
        parameters << klass.new(name, options[:default], options)
      end

      def url(location)
        @url = location
      end

      def parameters
        @parameters ||= []
      end

      def parameter_for(name)
        name = Parameter.normalize_name(name)
        parameters.find{|p| p.normalized_name == name}
      end
    end

    def initialize(attributes = {})
      @parameters      = []
      @parameters_hash = {}

      self.class.parameters.each do |p|
        @parameters << (@parameters_hash[p.normalized_name] = p.dup)
      end
      attributes.each_pair do |key, val|
        self[key] = val
      end
    end

    def parameter_for(key)
      @parameters_hash[Parameter.normalize_name(key)] or
        raise WebApi::ParameterNotFound, key.to_s
    end

    def [](key)
      parameter_for(key).value
    end

    def []=(key, value)
      parameter_for(key).value = value
    end

    def parameters
      @parameters
    end

    def query_string
      parameters.map{|p| p.validate; p.query_string} * '&'
    end

    def url
      cgi = self.class.instance_eval("@url") or raise WebApi::WebApiError, "Base Url is not set"
      "%s?%s" % [cgi, query_string]
    end

    def execute
      query_string
    end
  end
end

