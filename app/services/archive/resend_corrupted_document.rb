class Archive::ResendCorruptedDocument
  def self.execute(with_email = true)
    Archive::DocumentCorrupted.retryable.each do |document|
      new().execute(document)
    end

    if with_email
      Archive::DocumentCorrupted.to_notify.group_by{|doc| doc.params[:uploader] }.each do |uploader, documents|
        DocumentCorruptedAlertMailer.notify({ uploader: uploader, documents: documents }).deliver
        documents.each{ |doc| doc.update(is_notify: true) }
      end
    end

    # Archive::DocumentCorrupted.old_documents.each(&:destroy)
  end

  def execute(document)
    params = document.params
    uploaded_document = UploadedDocument.new(File.open(document.cloud_content_object.reload.path), params[:original_file_name], document.user, params[:journal], params[:prev_period_offset], params[:uploader], params[:api_name], params[:analytic], params[:api_id], false)

    errors = uploaded_document.errors

    if errors.any? && !uploaded_document.already_exist?
      document.error_message = uploaded_document.full_error_messages
      document.save

      if uploaded_document.corrupted_document? && document.retry_count < 2
        document.update(retry_count: document.retry_count + 1)
        document.ready
      else
        document.rejected
      end
    else
      document.uploaded
    end
  end
end