module SoftwareMod::Configuration
  extend ActiveSupport::Concern

  SOFTWARES ||= ['acd', 'ibiza', 'exact_online', 'my_unisoft', 'coala', 'sage_gec', 'quadratus', 'cegid', 'fec_agiris', 'fec_acd', 'csv_descriptor', 'cogilog', 'ciel']
  SOFTWARES_HUMAN_NAME ||= { acd: 'ACD', ibiza: 'iBiza', exact_online: 'Exact Online', my_unisoft: 'My Unisoft', coala: 'Coala', sage_gec: 'Sage GEC - Privé', quadratus: 'Quadratus', cegid: 'Cegid', fec_agiris: 'Agiris', fec_acd: 'FEC ACD', csv_descriptor: 'CSV', cogilog: 'Cogilog', ciel: 'Ciel' }
  TABLE_NAME_WITH_SOFTWARES_USING_API ||= ['software_ibizas', 'software_exact_online', 'software_my_unisofts', 'software_sage_gec', 'software_acd']
  #SOFTWARES_OBJECTS = [::SoftwareMod::Ibiza, ::SoftwareMod::ExactOnline, ::SoftwareMod::Cegid, ::SoftwareMod::Coala, ::SoftwareMod::SageGec, ::SoftwareMod::FecAgiris, ::SoftwareMod::FecAcd, ::SoftwareMod::Quadratus, ::SoftwareMod::CsvDescriptor, ::SoftwareMod::MyUnisoft, ::SoftwareMod::Cogilog, ::SoftwareMod::Ciel]

  def self.softwares_objects
    return [::SoftwareMod::Ibiza, ::SoftwareMod::ExactOnline, ::SoftwareMod::Cegid, ::SoftwareMod::Coala, ::SoftwareMod::SageGec, ::SoftwareMod::FecAgiris, ::SoftwareMod::FecAcd, ::SoftwareMod::Quadratus, ::SoftwareMod::CsvDescriptor, ::SoftwareMod::MyUnisoft, ::SoftwareMod::Cogilog, ::SoftwareMod::Ciel]
  end

  def self.softwares
    {
      ibiza:          SoftwareMod::Ibiza,
      exact_online:   SoftwareMod::ExactOnline,
      cegid:          SoftwareMod::Cegid,
      coala:          SoftwareMod::Coala,
      sage_gec:       SoftwareMod::SageGec,
      fec_agiris:     SoftwareMod::FecAgiris,
      acd:            SoftwareMod::Acd,
      fec_acd:        SoftwareMod::FecAcd,
      quadratus:      SoftwareMod::Quadratus,
      csv_descriptor: SoftwareMod::CsvDescriptor,
      my_unisoft:     SoftwareMod::MyUnisoft,
      cogilog:        SoftwareMod::Cogilog,
      ciel:           SoftwareMod::Ciel,
    }
  end

  def self.h_softwares
    {
      ibiza:          'ibiza',
      exact_online:   'exact_online',
      my_unisoft:     'my_unisoft',
      coala:          'coala',
      sage_gec:       'sage_gec',
      quadratus:      'quadratus',
      cegid:          'cegid',
      fec_agiris:     'fec_agiris',
      acd:            'acd',
      fec_acd:        'fec_acd',
      csv_descriptor: 'csv_descriptor',
      cogilog:        'cogilog',
      ciel:           'ciel',
    }.with_indifferent_access
  end

  def self.human_format
    {
      ibiza:          "iBiza",
      exact_online:   "Exact Online",
      my_unisoft:     "My Unisoft",
      coala:          "Coala",
      sage_gec:       "Sage GEC - Privé",
      quadratus:      "Quadratus",
      cegid:          "Cegid",
      fec_agiris:     "Fec Agiris",
      acd:            'acd',
      fec_acd:        "Fec ACD",
      csv_descriptor: "Autre(format d'export .csv)",
      cogilog:        "Cogilog",
      ciel:           "Ciel",
    }.with_indifferent_access
  end

  def self.softwares_table_name
    {
      ibiza:          'software_ibizas',
      exact_online:   'software_exact_online',
      my_unisoft:     'software_my_unisofts',
      coala:          'software_coalas',
      sage_gec:       'software_sage_gec',
      quadratus:      'software_quadratus',
      cegid:          'software_cegids',
      fec_agiris:     'software_fec_agiris',
      acd:            'software_acd',
      fec_acd:        'software_fec_acds',
      csv_descriptor: 'software_csv_descriptors',
      cogilog:        'software_cogilog',
      ciel:           'software_ciel',
    }.with_indifferent_access
  end

  def self.software_object_name
    {
      'SoftwareMod::Ibiza'         => 'ibiza',
      'SoftwareMod::ExactOnline'   => 'exact_online',
      'SoftwareMod::Cegid'         => 'cegid',
      'SoftwareMod::Coala'         => 'coala',
      'SoftwareMod::SageGec'       => 'sage_gec',
      'SoftwareMod::FecAgiris'     => 'fec_agiris',
      'SoftwareMod::Acd'           => 'acd',
      'SoftwareMod::FecAcd'        => 'fec_acd',
      'SoftwareMod::Quadratus'     => 'quadratus',
      'SoftwareMod::CsvDescriptor' => 'csv_descriptor',
      'SoftwareMod::MyUnisoft'     => 'my_unisoft',
      'SoftwareMod::Cogilog'       => 'cogilog',
      'SoftwareMod::Ciel'          => 'ciel',
    }
  end

  def auto_deliver?
    return false if self.owner.is_a?(User) && auto_deliver === false
    return true  if self.owner.is_a?(User) && auto_deliver === true

    (self.owner.is_a?(User) && auto_deliver == -1) ? self.owner.organization.auto_deliver?(self) : (auto_deliver == 1)
  end

  def used?
    if self.is_a?(SoftwareMod::Ibiza)
      if owner_type == 'User'
        is_used
      else
        is_used && ( access_token.present? || access_token_2.present? )
      end
    else
      is_used
    end
  end
end