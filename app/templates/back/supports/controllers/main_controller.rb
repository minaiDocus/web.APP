# frozen_string_literal: true
class Admin::Supports::MainController < BackController
  prepend_view_path('app/templates/back/supports/views')

  # GET /admin/supports
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
    @operations = @operations.where("api_id = ?", params[:ope_api_id])                                                          if params[:ope_api_id].present?

    # @operations = @operations.where(is_coming: false, deleted_at: nil, processed_at: nil)                                        if @operations.try(:any?)

    @operations = @operations.order(sort_column => sort_direction).page(params[:page]).per(params[:per_page])                   if @operations.try(:any?)

    if @operations.try(:any?)
      render partial: "get_operations"
    else
      render plain: 'Aucun résultat'
    end   
  end

  def get_flux_bridge    
    if params[:bridge_code_user].present? && params[:bridge_bank_ids].present? && params[:ope_date].present?
      date       = params[:ope_date].split('-')

      user       = User.find_by_code params[:bridge_code_user]
      start_time = Time.new(date[0],date[1], date[2])

      b_ids      = params[:bridge_bank_ids].present? ? [params[:bridge_bank_ids]] : []
      if user
        begin
          Bridge::GetTransactions.new(user).execute(start_time, b_ids)
        rescue => e
          render plain: e.to_json
        end

        render plain: 'Récupération Flux lancer'
      else
        render plain: "Le client n'existe pas"
      end      
    else
      render plain: 'Paramètre manquant'
    end    
  end

  def get_ba_free
    if params[:bridge_code_user].present?
      user = User.find_by_code params[:bridge_code_user]

      if user
        access_token = Bridge::Authenticate.new(user).execute

        begin
          @accounts    = BridgeBankin::Account.list(access_token: access_token)

          render partial: "get_bridge_accounts"
        rescue => e
          render plain: e.to_json
        end        
      else
        render plain: "Le client n'existe pas"
      end
    else
      render plain: 'Paramètre manquant'
    end    
  end

  def get_transaction_free
    if params[:bridge_code_user].present? && params[:bridge_bank_ids].present? && params[:ope_date].present?
      user = User.find_by_code params[:bridge_code_user]
      date = params[:ope_date].split('-')

      if user        
        access_token = Bridge::Authenticate.new(user).execute
        start_time   = Time.new(date[0],date[1], date[2])

        begin
          bank_account = user.bank_accounts.find params[:bridge_bank_ids]
          @transactions = BridgeBankin::Transaction.list_by_account(account_id: bank_account.api_id, access_token: access_token, since: start_time)


          render partial: "get_transaction_free"
        rescue => e
          render plain: e.to_json
        end
      else
        render plain: "Le client n'existe pas"
      end
    else
      render plain: 'Paramètre manquant'
    end  
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

  def resend_operation
    operations = Operation.where(id: params[:ids]) 

    operations.each do |operation|      
      operation.update(is_locked: false) if not operation.to_lock?     
    end

    render plain: "Modifié avec succès"
  end

  def resend_to_preassignment
    pieces = Pack::Piece.where(id: params[:ids])

    pieces.each do |piece|
      piece.preseizures.destroy_all

      piece.pre_assignment_state = "waiting"
      piece.created_at           = Time.now if piece.created_at < 3.month.ago

      piece.save 
    end

    render plain: "Modifié avec succès"
  end

  def resend_delivery
    # report_preseizures = Pack::Report::Preseizure.where(id: params[:ids]).group_by(&:report)
    # report_preseizures = Pack::Report::Preseizure.last(10).group_by(&:report)

    # report_preseizures.each do |report_preseizure|
    #   debugger
      
    #   # preseizure.is_locked = false
    #   # PreAssignment::CreateDelivery.new(grouped_preseizures, ['ibiza', 'exact_online', 'my_unisoft', 'sage_gec', 'acd'], {force: true}).execute
    #   # PreAssignment::CreateDelivery.new(preseizure).execute
    # end

    render plain: "Modifié avec succès"
  end

  def get_pieces
    if params[:pack_piece_name].present?
      @pieces = Pack.find_by_name(params[:pack_piece_name].strip + ' all')&.pieces.presence || []
    else
      @pieces = params[:piece_name].present? ? Pack::Piece.find_by_name(params[:piece_name].strip) : []
    end

    if @pieces.try(:any?)
      @pieces = @pieces.order(sort_column => sort_direction).page(params[:page]).per(params[:per_page])

      render partial: 'get_pieces'
    else
      render plain: 'Aucun résultat'
    end 
  end

  def get_preseizures
    if params[:preseizure_date].present?
      @preseizures = Pack::Report::Preseizure.where("pack_report_preseizures.date BETWEEN '#{CustomUtils.parse_date_range_of(params[:preseizure_date]).join("' AND '")}'")
    elsif params[:pack_piece_name].present?
      @preseizures = Pack.find_by_name(params[:pack_piece_name].strip + ' all')&.preseizures.presence || []
    else
      @preseizures = params[:piece_name].present? ? Pack::Piece.find_by_name(params[:piece_name].strip)&.preseizures : []
    end

    if @preseizures.try(:any?)
      @preseizures = @preseizures.order(sort_column => sort_direction).page(params[:page]).per(params[:per_page])

      render partial: 'get_preseizures'
    else
      render plain: 'Aucun résultat'
    end 
  end

  def get_temp_document
    if params[:pack_piece_name].present?
      temp_pack = TempPack.find_by_name(params[:pack_piece_name].to_s + ' all')

      if temp_pack
        @temp_documents = temp_pack.temp_documents.order(sort_column => sort_direction).page(params[:page]).per(params[:per_page])

        render partial: "get_temp_document"
      else
        render plain: "Le pack n'existe pas"
      end
    else
      render plain: 'Paramètre manquant'
    end    
  end

  def destroy_temp_document
    temp_documents = TempDocument.where(id: params[:ids])

    if temp_documents
      temp_documents.each do |temp_document|
        temp_documents.destroy if %(created ocr_needed unreadable wait_selection).include?(temp_document.state)
      end
      
      render plain: "Temp Document supprimé"
    else
      render plain: "Erreur lors de suppression : #{temp_documents.errors.messages}"
    end    
  end

  def delete_fingerprint_temp_document
    temp_documents = TempDocument.where(id: params[:ids])

    if temp_documents
      temp_documents.update(original_fingerprint: "")

      render plain: "fingerprint supprimé"
    else
      render plain: "Temp document n'existe pas"
    end    
  end

  def set_delivery_external
    if params[:code_client].present?
      user = User.get_by_code params[:code_client]

      if user
        user.remote_files.not_processed.map(&:waiting!)

        render plain: "Livraison relancer"

      else
        render plain: "Le client n'existe pas"
      end
    else
      render plain: 'Paramètre manquant'
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