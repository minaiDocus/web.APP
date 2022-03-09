class PonctualScripts::RollbackPeriods < PonctualScripts::PonctualScript
  def self.execute
    new().run
  end

  def self.rollback
    new().rollback
  end

  private

  def execute
    periods   = Period.where(organization_id: nil).where("DATE_FORMAT(start_date, '%Y%m') >= '202011' AND DATE_FORMAT(start_date, '%Y%m') <= '202011'")

    data_each = []
    data_each << ["user_code", "id", "key", "curr_value", "new_value", "period_date", "date_audit"]

    periods.each do |period|
      next if not period.user
      next if period.user.organization.try(:code) != 'EXT'
      next if period.user.code.to_s.match /IDOC%/i

      period_audit = period.audits.where(action: 'update').where('audited_changes LIKE "%price_in_cents_wo_vat%"').except(:order).order(version: :desc)

      _break = false
      prim_audit = nil
      period_audit.each do |audit|
        next if _break

        if audit.audited_changes.to_s.match /price_in_cents_wo_vat/i
          if audit.created_at.strftime('%Y%m%d') > period.end_date.strftime('%Y%m%d') && audit.created_at.strftime('%d%H').to_i > 107
            prim_audit = audit
            next
          end

          next if not prim_audit

          prim_audit.audited_changes.each do |k, v|
            key        = k.to_s
            prev_value = period[k.to_sym]
            new_value  = v[0]

            if prev_value != new_value
              period[k.to_sym] = new_value
              data_each << [ period.user.code, period.id, key, prev_value, new_value, period.start_date, prim_audit.created_at.strftime("%Y-%m-%d %H:%M:%S") ]
            end
          end

          _break = true
          period.save
        end
      end
    end


    send_mail_for(data_each)
  end

  def backup
    dir = Rails.root.join('files');
    file_path = File.join(dir, "rollback_periods.csv")

    if !File.exist?(file_path)
      datas = File.read(file_path)

      datas.each do |line|
        col = line.split('|')

        id = col[0].strip
        key = col[1].strip
        prev_value = col[2].strip
        next_value = col[3].strip

        period = Period.where(id: id).first

        if period
          period[key.to_sym] = prev_value
          period.save
        else
          logger_infos "[ROLLBACK PERIODS] - period : #{id.to_s} - not found"
        end
      end
    else
      logger_infos "[ROLLBACK PERIODS] - #{file_path} - doesnt exist"
    end
  end

  def send_mail_for(datas)
    lines = []
    datas.each do |data|
      lines << data.join('|')
    end

    dir = Rails.root.join('files');
    file_path = File.join(dir, "rollback_periods.csv")

    File.write(file_path, lines.join("\n"));

    log_document = {
      subject: "[RollbackPeriod] - Rollback changed periods All Period ",
      name: "RollbackPeriod",
      error_group: "[RollbackPeriod] Rollback changed periods All Period ",
      erreur_type: "[RollbackPeriod] - Rollback changed periods All Period ",
      date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S')
    }

    begin
      ErrorScriptMailer.error_notification(log_document, { attachements: [{name: "rollback_periods.csv", file: File.read(file_path)}]} ).deliver
    rescue
      ErrorScriptMailer.error_notification(log_document).deliver
    end

    p file_path
  end
end