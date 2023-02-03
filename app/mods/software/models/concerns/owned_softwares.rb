module SoftwareMod::OwnedSoftwares
  extend ActiveSupport::Concern

  included do
    has_one :acd, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::Acd'
    has_one :ibiza, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::Ibiza'
    has_one :coala, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::Coala'
    has_one :exact_online, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::ExactOnline'
    has_one :quadratus, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::Quadratus'
    has_one :fec_agiris, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::FecAgiris'
    has_one :fec_acd, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::FecAcd'
    has_one :cegid, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::Cegid'
    has_one :csv_descriptor, as: :owner, autosave: true, dependent: :destroy, class_name: 'SoftwareMod::CsvDescriptor'
    has_one :my_unisoft, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::MyUnisoft'
    has_one :sage_gec, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::SageGec'
    has_one :cogilog, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::Cogilog'
    has_one :ciel, as: :owner, dependent: :destroy, class_name: 'SoftwareMod::Ciel'
  end
end