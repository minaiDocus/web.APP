# -*- encoding : UTF-8 -*-
module CegidCfeLib
  class DataBuilder
    def initialize(preseizures)
      @preseizures    = preseizures
      @data_count     = 0
      @error_messages = []
    end

    def execute
      response = { data: data_content }

      response[:data_count] = @data_count
      response[:error_messages] = full_error_messages

      if full_error_messages.empty?
        response[:data_built] = true
      else
        response[:data_built] = false
      end

      response
    end

    private

    def data_content
      begin
        PreseizureExport::Software::Cegid.new(preseizures, 'tra_cegid_cfe').execute
      rescue => e
        @error_messages << e
      end
    end

    def full_error_messages
      @error_messages.join(',')
    end
  end
end