module SoftwareMod::UserModule
  extend ActiveSupport::Concern

  def self.using_by_software(software)
    if software.in? SoftwareMod::Configuration::SOFTWARES
      self.all.joins(software.to_sym).where("#{SoftwareMod::Configuration.softwares_table_name[software.to_sym]}".to_sym => { is_used: true } )
    end
  end


  def csv_descriptor!
    self.csv_descriptor ||= Software::CsvDescriptor.create(owner_id: id)
  end



  def self.filter_by_software(software=nil)
    response = self.all

    response.map do |user|
      next if user.collaborator?

      case software
        when 'ibiza'
          skip_user = user.uses?(:exact_online) || user.uses?(:my_unisoft) || user.uses?(:sage_gec) || user.uses?(:acd)
        when 'exact_online'
          skip_user = user.uses?(:ibiza) || user.uses?(:my_unisoft) || user.uses?(:sage_gec) || user.uses?(:acd)
        when 'my_unisoft'
          skip_user = user.uses?(:ibiza) || user.uses?(:exact_online) || user.uses?(:sage_gec) || user.uses?(:acd)
        when 'sage_gec'
          skip_user = user.uses?(:ibiza) || user.uses?(:exact_online) || user.uses?(:my_unisoft) || user.uses?(:acd)
        when 'acd'
          skip_user = user.uses?(:ibiza) || user.uses?(:exact_online) || user.uses?(:my_unisoft) || user.uses?(:sage_gec)
        else
          skip_user = false
      end

      next if skip_user
      user
    end
  end



end