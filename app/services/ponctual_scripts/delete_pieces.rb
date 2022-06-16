class PonctualScripts::DeletePieces < PonctualScripts::PonctualScript
  def self.execute(options)    
    new(options).run
  end

  def self.rollback(options)
    new(options).rollback
  end

  private 

  def execute
    @save_pack_id = nil
    @list_deleted_pieces = []
    @list_pieces_with_error = []
    @error_process = false


    @user = User.find_by_code(@options[:user_code])
    if @user != nil
      all_pieces = @user.pieces
      all_packs = @user.packs
      logger_infos " Utilisateur trouvé:  #{@user.name} (code associé : #{@options[:user_code]}) " 
      logger_infos " Nombre de packs dans le dossier : #{all_packs.size.to_s} ====== Nombre total des pièces : #{all_pieces.size.to_s}. "
    else
      logger_infos " Impossible de trouver l'utilisateur associé au code : #{@options[:user_code]} " 
      return
    end

     logger_infos " ================================ [Début du processus] =========================== "
     

     all_pieces.each do |piece|
        delete_piece(piece)
        if @save_pack_id == nil || piece.pack_id != @save_pack_id
          pack = piece.pack
          logger_infos " Pack: #{pack.id} - #{pack.name} "
          logger_infos " pack.recreate_original_document "
          pack.delay.try(:recreate_original_document) if pack
          @save_pack_id = piece.pack_id
          pack = nil
        end
     end


    logger_infos " ================================ [Fin du processus] =========================== "
    logger_infos " Nombre total de pièces supprimées = #{@list_deleted_pieces.size}. "
    logger_infos " Pièce(s) supprimée(s) avec succès : [#{@list_deleted_pieces.join(', ')}]. " if @list_deleted_pieces.size > 0
    logger_infos " Nombre total de pièces qui ont rencontré des erreurs lors de la suppression = #{@list_pieces_with_error.size}. "
    if @list_pieces_with_error.size > 0
      logger_infos " Pièce(s) non supprimée(s) : [#{@list_pieces_with_error.join(', ')}]. "
    end
  end

  def backup
  end

  def delete_piece(piece)
    logger_infos " Suppression de la pièce : #{piece.id.to_s} - #{piece.name} en cours ....................... "
    piece.delete_at = DateTime.now
    piece.delete_by = "IDOC%DEV5"
    if piece.save
      @list_deleted_pieces << piece.id.to_s
    else
      @error_process = true
      @list_pieces_with_error << piece.id.to_s
    end

    temp_document = piece.temp_document

    if temp_document
      temp_document.original_fingerprint    = nil
      temp_document.content_fingerprint     = nil
      temp_document.raw_content_fingerprint = nil
      temp_document.save

      parents_documents = temp_document.parents_documents

      if parents_documents.any?
        parents_documents.each do |parent_document|
          blank_children =  parent_document.children.select{ |child| child.fingerprint_is_nil? }

          if parent_document.children.size == blank_children.size
            parent_document.original_fingerprint    = nil
            parent_document.content_fingerprint     = nil
            parent_document.raw_content_fingerprint = nil
            parent_document.save
          end
        end
      end
    end
    if @error_process
      logger_infos " Une erreur est survenue lors de la suppression de la pièce #{piece.id.to_s} - #{piece.name}. "
      @error_process = false
    else
      logger_infos " Pièce supprimée avec succès. "
      end
  end


end