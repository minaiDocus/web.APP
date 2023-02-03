module FileDelivery::RemoteFile
  ALL           = 0
  REPORT        = 3
  PIECES_ONLY   = 2
  ORIGINAL_ONLY = 1


  def kzip_options
    user = pack.owner

    _preseizures = preseizures
    _preseizures = [nil] unless _preseizures.any?

    _preseizures.map do |preseizure|
      period = if preseizure
                 preseizure.date.to_date
               else
                 DocumentTools.to_period(name)
               end

      exercise = IbizaLib::ExerciseFinder.new(user, period, user.organization.ibiza).execute

      domain = user.account_book_types.where(name: journal).first.try(:domain)
      nature = nil

      if domain == 'AC - Achats'
        nature = 'Autres'
      elsif domain == 'BQ - Banque'
        nature = 'Relevés'
      end

      options = {}
      options[:user_code]       = user.code
      options[:user_company]    = user.company

      if exercise
        options[:exercise]      = true
        options[:start_time]    = exercise.start_date.to_time
        options[:end_time]      = exercise.end_date.to_time
      else
        options[:exercise]      = false
      end

      options[:date]            = period.to_time
      options[:domain]          = domain
      options[:nature]          = nature
      options[:file_name]       = DocumentTools.file_name name

      options.with_indifferent_access
    end
  end

  def get_remote_file(object, service_name, extension = '.pdf')
    remote_file = remote_files.of(object, service_name).with_extension(extension).first

    mcf_passed = (service_name == 'My Company Files' && user.mcf_storage.nil?) ? false : true

    if remote_file.nil? && mcf_passed
      remote_file              = RemoteFile.new
      remote_file.receiver     = object
      remote_file.pack         = self.is_a?(Pack) ? self : pack #remote file can be document or pack itself
      remote_file.service_name = service_name
      remote_file.remotable    = self

      remote_file.save
    end

    remote_file
  end


  def get_remote_files(object, service_name)
    current_remote_files = []

    current_remote_files << get_remote_file(object, service_name)

    current_remote_files.compact
  end
end
