# -*- encoding : UTF-8 -*-
module CegidCfeLib
  class Setup
    def initialize(params)
      @organization = params[:organization]
      @customer     = params[:customer]
      @params       = params[:columns]
    end

    def execute
      @cegid_cfe = @customer.nil? ? @organization.cegid_cfe.presence : @customer.cegid_cfe.presence

      @cegid_cfe = Software::CegidCfe.new if @cegid_cfe.nil?

      @owner      = nil

      unless @customer
        @owner = @organization

        update_and_save
      else
        @owner    = @customer

        if @params[:action] == "update"
          return false if !@params[:is_used] && @cegid_cfe.nil?

          return true if !@params[:is_used] && @cegid_cfe.present? && @cegid_cfe.destroy

          update_and_save
        else
          if @params[:remove_customer]
            @cegid_cfe.sage_private_api_uuid = nil
            @cegid_cfe.auto_deliver  = -1

            return true if @cegid_cfe.save
          end

          update_and_save
        end
      end

      true
    end

    private

    def update_and_save
      @cegid_cfe.owner           = @owner
      @cegid_cfe.auto_deliver    = @params[:auto_deliver]  if @params[:auto_deliver].present?
      @cegid_cfe.is_used         = @params[:is_used]       if @params[:is_used].to_s.present?

      @cegid_cfe.save!
    end
  end

end