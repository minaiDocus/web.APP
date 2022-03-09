class PonctualScripts::CheckAllPeriod
  def execute    
    periods   = Period.where(organization_id: nil).where("DATE_FORMAT(created_at, '%Y') >= '2022'")

    data_each = []
    data_each << ["PERIOD ID", "PERIOD", "USER CODE", "DATE DEBUT", "DATE FIN", "DATE MAJ", "CONTENT", "ADRESS IP"]

    periods.each do |period|
      next if not period.user
      next if period.user.code.to_s.match /IDOC%/i

      period_audit = period.audits.where(action: 'update')

      period_audit.each do |audit|
        if audit.audited_changes.to_s.match /price_in_cents_wo_vat/i
          next if audit.created_at.strftime('%Y%m%d') <= period.end_date.strftime('%Y%m%d')

          data_each << [ period.id, period.start_date.strftime('%Y%m'), period.user.code, period.start_date, period.end_date, audit.created_at.strftime('%Y-%m-%d %H:%M:%S'), audit.audited_changes, audit.remote_address]

          data_each << ["","","",""]
        end
      end
    end

    send_mail_for(data_each)
  end

  private

  def send_mail_for(datas)
    lines = []
    datas.each do |data|
      lines << data.join('|')
    end

    CustomUtils.mktmpdir('export_period', nil, false) do |dir|
      file_path = File.join(dir, "export_period.csv")

      File.write(file_path, lines.join("\n"));

      log_document = {
        subject: "[CheckPeriod] Exportation All Period ",
        name: "CheckPeriod",
        error_group: "[CheckPeriod] Exportation All Period ",
        erreur_type: "[CheckPeriod] - Exportation All Period ",
        date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S')
      }

      begin
        ErrorScriptMailer.error_notification(log_document, { attachements: [{name: "export_period.csv", file: File.read(file_path)}]} ).deliver
      rescue
        ErrorScriptMailer.error_notification(log_document).deliver
      end

      p file_path
    end
  end
end