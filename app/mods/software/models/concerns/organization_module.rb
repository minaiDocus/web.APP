module SoftwareMod::OrganizationModule
  extend ActiveSupport::Concern

  def create_csv_descriptor
    SoftwareMod::CsvDescriptor.create(owner_id: id)
  end

  def uses_softwares?
    uses_api_softwares? || uses_non_api_softwares?
  end

  def uses_api_softwares?
    exact_online.try(:used?) || ibiza.try(:configured?) || my_unisoft.try(:used?) || sage_gec.try(:used?) || acd.try(:used?)
  end

  def uses_non_api_softwares?
    coala.try(:used?) || quadratus.try(:used?) || cegid.try(:used?) || csv_descriptor.try(:used?) || fec_agiris.try(:used?) || fec_acd.try(:used?)
  end

  def auto_deliver?(_software)
    @software = _software

    self.try(software.to_sym).auto_deliver == 1
  end

  def compta_analysis_activated?(_software)
    @software = _software

    self.try(software.to_sym).is_analysis_activated == 1
  end

  def analysis_to_validate?(_software)
    @software = _software

    self.try(software.to_sym).is_analysis_to_validate == 1
  end

  private

  def software
    if SoftwareMod::Configuration.softwares_objects.include?(@software) || @software.is_a?(ActiveRecord::Base)
      @software = @software.to_s.split('<')[1].split(':0x')[0]
      @software = SoftwareMod::Configuration.software_object_name[@software]
    end

    @software
  end

end