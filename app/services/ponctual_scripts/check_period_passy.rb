class PonctualScripts::CheckPeriodPassy
  def initialize(user_code=nil, start_date=nil)
    @user_code  = user_code.presence || 'FIDC%PASSY'
    @start_date = start_date.presence || 202101
  end

  def execute
    user      = User.find_by_code(@user_code)
    periods   = user.periods.where("DATE_FORMAT(start_date, '%Y%m') >= ?", @start_date)

    data_each = []
    data_each << ["PERIOD", "ETAT", "CONTENT", "CODE USER", "ADRESS IP", "DATE MAJ"]

    periods.each do |period|
      on_create = period.audits.where(action: 'create').first

      data_each << [ period.start_date.strftime('%Y%m'), on_create.action, on_create.audited_changes, on_create.try(:user_id), on_create.remote_address, on_create.created_at.strftime('%Y-%m-%d %H:%M:%S') ]

      on_change = period.audits.where(action: 'update')

      on_change.each do |change|
        data_each << [ period.start_date.strftime('%Y%m'), change.action, change.audited_changes, change.try(:user_id), change.remote_address, change.created_at.strftime('%Y-%m-%d %H:%M:%S') ]
      end

      data_each << ["","","",""]
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
        subject: "[CheckPeriod] Exportation Period #{@user_code} depuis #{@start_date}",
        name: "CheckPeriod",
        error_group: "[CheckPeriod] Exportation Period #{@user_code} depuis #{@start_date}",
        erreur_type: "[CheckPeriod] - Exportation Period #{@user_code} depuis #{@start_date}",
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