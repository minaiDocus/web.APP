class Notifications::DematboxUploaded < Notifications::Notifier
  include Concurrent::Async

  def self.notify_dematbox_document_uploaded(arguments={})
    new(arguments).notify_dematbox_document_uploaded
  end

  def initialize(arguments={})
    super
  end

  def notify_dematbox_document_uploaded
    sleep(20) #IMPORANT: wait a few seconds before sending notification to dematbox

    temp_document = TempDocument.find(@arguments[:temp_document_id])

    if temp_document.dematbox_box_id && temp_document.dematbox_doc_id && !temp_document.dematbox_is_notified
      pages_number = DocumentTools.pages_number(temp_document.cloud_content_object.path)
      message = 'Envoi OK : %02d p.' % pages_number

      begin
        result = DematboxApi.notify_uploaded temp_document.dematbox_doc_id, temp_document.dematbox_box_id, message
      rescue Savon::SOAPFault => e
        log_document = {
          subject: "[Dematbox] - Can't notify document",
          name: "Unotified_documents",
          error_group: "[Dematbox] : Unotified document",
          erreur_type: "Dematbox - Unotified document",
          date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
          more_information: {
            td: temp_document.inspect,
            dematbox_box_id: temp_document.dematbox_box_id,
            dematbox_doc_id: temp_document.dematbox_doc_id,
            error: e.message
          }
        }

        ErrorScriptMailer.error_notification(log_document).deliver

        if e.message.match(/702:DocId already notified/)
          result = true
        elsif e.message.match(/703:DocId not sent/) && @arguments[:remaining_tries] > 0 && Rails.env == 'production'
          sleep(30)
          Notifications::DematboxUploaded.new({ temp_document_id: @arguments[:temp_document_id], remaining_tries: (@arguments[:remaining_tries] - 1) }).notify_dematbox_document_uploaded
        else
          if @arguments[:remaining_tries] > 0 && Rails.env == 'production'
            Notifications::DematboxUploaded.new({ temp_document_id: @arguments[:temp_document_id], remaining_tries: (@arguments[:remaining_tries] - 1) }).notify_dematbox_document_uploaded
          else
            raise
          end
        end
      end

      if result == '200:OK' || result == true
        temp_document.update(dematbox_is_notified: true, dematbox_notified_at: Time.now)

        # Note : not used, since we do not process OCR through Sagemcom anymore
        # if temp_document.uploaded?
        #   DematboxServiceApi.upload_notification temp_document.dematbox_doc_id, temp_document.dematbox_box_id
        # end
      end
    end

    log_document = {
      subject: "[Dematbox] - Document notification",
      name: "document_notification_dematbox",
      error_group: "[Dematbox] - Document notification",
      erreur_type: "Dematbox - Document notification",
      date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
      more_information: {
        from: @arguments[:from],
        td: temp_document.try(:id),
        dematbox_box_id: temp_document.try(:dematbox_box_id),
        dematbox_doc_id: temp_document.try(:dematbox_doc_id),
        Notified_at: temp_document.dematbox_notified_at,
        result: result.to_s
      }
    }

    ErrorScriptMailer.error_notification(log_document).deliver
  end
end
