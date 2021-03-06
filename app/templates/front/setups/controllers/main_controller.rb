# frozen_string_literal: true
class Setups::MainController < OrganizationController
  before_action :load_customer

  ######### NE PAS TOUCHER / BOL DE SPAGHETTI / OU ALORS PASSER LA JOURNÉE A TESTER ##########

  # GET /organizations/:organization_id/customers/:customer_id/setup/next
  def next
    if @customer.configured?
      redirect_to organization_customer_path(@organization, @customer)
    else
      next_configuration_step
    end
  end

  # GET /organizations/:organization_id/customers/:customer_id/setup/previous
  def previous
    if @customer.configured?
      redirect_to organization_customer_path(@organization, @customer)
    else
      previous_configuration_step
    end
  end

  # GET /organizations/:organization_id/customers/:customer_id/setup/resume
  def resume
    if !@customer.last_configuration_step.nil?
      step = @customer.current_configuration_step = @customer.last_configuration_step
      result = @customer.last_configuration_step = nil
      if step == 'softwares_selection'
        result = if @organization.uses_softwares?
                   'softwares_selection'
                 elsif @customer.is_package?('preassignment_active')
                   'compta_options'
                 elsif @customer.authorized_upload?
                   'period_options'
                 else
                   'journals'
                 end
      elsif step == 'compta_options'
        result = if @customer.is_package?('preassignment_active')
                   'compta_options'
                 elsif @customer.authorized_upload?
                   'period_options'
                 else
                   'journals'
                 end
      elsif step == 'period_options'
        result = if @customer.authorized_upload?
                   'period_options'
                 elsif @customer.is_package?('preassignment_active')
                   if @organization.ibiza.try(:configured?) && @customer.uses?(:ibiza)
                     'ibiza'
                   elsif @customer.uses?(:csv_descriptor)
                     'use_csv_descriptor'
                   else
                     'accounting_plans'
                            end
                 else
                   'journals'
                 end
      elsif step.in?(%w[ibiza use_csv_descriptor])
        result = if @customer.is_package?('preassignment_active')
                   if @organization.ibiza.try(:configured?) && @customer.uses?(:ibiza)
                     'ibiza'
                   elsif @customer.uses?(:csv_descriptor)
                     'use_csv_descriptor'
                   else
                     'accounting_plans'
                            end
                 else
                   'journals'
                 end
      elsif step == 'csv_descriptor'
        result = if @customer.is_package?('preassignment_active')
                   if @customer.try(:csv_descriptor).try(:use_own_format?)
                     'csv_descriptor'
                   else
                     'use_csv_descriptor'
                            end
                 else
                   'journals'
                 end
      elsif step.in?(%w[accounting_plans vat_accounts exercises])
        result = if @customer.is_package?('preassignment_active')
                   if @organization.ibiza.try(:configured?) && @customer.uses?(:ibiza)
                     'ibiza'
                   else
                     step
                            end
                 else
                   'journals'
                 end
      elsif step == 'journals'
        result = 'journals'
      elsif step == 'order_paper_set'
        if @customer.is_package?('mail_active') && (@customer.orders.paper_sets.empty? || @customer.orders.paper_sets.pending.first)
          result = 'order_paper_set'
        elsif @customer.my_package.try(:scan_active) && (@customer.orders.dematboxes.empty? || @customer.orders.dematboxes.pending.first)
          result = 'order_dematbox'
        elsif @customer.is_package?('bank_active')
          result = 'retrievers'
        else
          result = 'ged'
        end
      elsif step == 'order_dematbox'
        if @customer.my_package.try(:scan_active) && (@customer.orders.dematboxes.empty? || @customer.orders.dematboxes.pending.first)
          result = 'order_dematbox'
        elsif @customer.is_package?('bank_active')
          result = 'retrievers'
        else
          result = 'ged'
        end
      elsif step == 'retrievers'
        result = if @customer.is_package?('bank_active')
                   'retrievers'
                 else
                   'ged'
                 end
      else
        result = 'ged'
      end
      @customer.current_configuration_step = result
      @customer.save
      redirect_to step_path(@customer.current_configuration_step)
    else
      redirect_to organization_customer_path(@organization, @customer)
    end
  end

  # GET /organizations/:organization_id/customers/:customer_id/setup/complete_later
  def complete_later
    unless @customer.configured?
      @customer.last_configuration_step = @customer.current_configuration_step
      @customer.current_configuration_step = nil
      @customer.save
    end
    redirect_to organization_customer_path(@organization, @customer)
  end
end