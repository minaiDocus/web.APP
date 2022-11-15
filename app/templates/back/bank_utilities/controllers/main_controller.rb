# frozen_string_literal: true
class Admin::BankUtilities::MainController < BackController
  prepend_view_path('app/templates/back/bank_utilities/views')

  # GET /admin/bank_utilities
  def index; end

  def get_retriever
    @user = User.find_by_code(params[:user_code]) if not params[:user_code].blank?

    if @user
      render partial: "get_retriever"
    else
      render plain: 'Aucun résultat'
    end  	
  end

  def get_bank_accounts
    @retriever = Retriever.find params[:retriever_id]

    if @retriever
      render partial: "get_bank_accounts"
    else
      render plain: 'Aucun résultat'
    end   
  end  

  def get_operations
    @operations = params[:ope_bank_id].present? ? BankAccount.find(params[:ope_bank_id]).operations : Operation.all

    if !params[:ope_user_code].blank?
      user = User.find_by_code(params[:ope_user_code].strip)

      @operations = @operations.where("user_id = #{user.try(:id)}")
    end

    @operations = @operations.where("label LIKE '%#{params[:ope_label]}%'")                                                     if params[:ope_label].present?
    @operations = @operations.where("date BETWEEN '#{CustomUtils.parse_date_range_of(options[:created_at]).join("' AND '")}'")  if params[:ope_date].present?
    @operations = @operations.where(is_coming: false,deleted_at: nil, processed_at: nil)                                        if @operations.try(:any?)

    @operations = @operations.order(sort_column => sort_direction).page(params[:page]).per(params[:per_page])                   if @operations.try(:any?)

    if @operations.try(:any?)
      render partial: "get_operations"
    else
      render plain: 'Aucun résultat'
    end   
  end

  def user_reset_password
    @user = User.find_by_code(params[:user_code]) if not params[:user_code].blank?

    new_password   = SecureRandom.hex(10)
    @user.password = new_password

    if @user.save
      render plain: "Nouveau MDP : #{new_password}"
    else
      render plain: 'Action avorté'
    end    
  end

  def get_bank_accounts_bridge
    
  end

  def get_transaction_bridge
    
  end

  def resume_me
    retriever = Retriever.find params[:retriever_id]

    if retriever
      retriever.resume_me(true)

      render plain: "Resume automate réussi"
    else
      render plain: 'Action avorté'
    end    
  end


  def switch
    user = User.find_by_code(params[:user_code]) if not params[:user_code].blank?

    if user
      bank = (params[:to] == "budgea_to_bridge") ? 'bridge' : 'budget_insight'

      user.options.update_attribute(:default_banking_provider, bank)

      render plain: "#{user.code} basculé vers #{bank.capitalize}"
    else
      render plain: 'Modification non éffectué'
    end
    
  end

  private

  def sort_column
    params[:sort] || 'created_at'
  end
  helper_method :sort_column

  def sort_direction
    params[:direction] || 'desc'
  end
  helper_method :sort_direction
end