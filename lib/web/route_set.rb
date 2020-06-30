require 'forwardable'

module Web
  class RouteSet
    extend Forwardable

    attr_reader :request

    def_delegators :@request, :params, :response

    def initialize(request)
      @request = request
    end

    def self.call(*args, **kwargs)
      new(*args, **kwargs)
    end

    def self.[](*args, **kwargs)
      new(*args, **kwargs)
    end

    private

    def with_validation(schema, params, &block)
      validation_result = schema.call(params)

      if validation_result.success?
        block.call(validation_result.to_h)
      else
        response.status = :bad_request

        validation_result.errors.to_h
      end
    end
  end
end
