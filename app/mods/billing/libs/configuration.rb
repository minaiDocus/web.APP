class BillingMod::Configuration
  LISTS = {
            ido_premium: {
              human_name: "iDo'Premium",
              description: "Vous permet de transférer vos pièces sans limite de quota.",
              hint: "Facture à 3.000 € pour les 150 premiers dossiers, au delà des 150 dossiers : 10€/dossiers",
              label: 'Téléchargement + Pré-saisie comptable',
              price: 3000,
              customers_limit: 150,
              unit_price: 10,
              commitment: 0,
              data_flows: { max: 0, duration: 'month', excess_price: 10 },
              options: { upload: 'strict', bank: 'optional', scan: 'strict', mail: 'optional', preassignment: 'strict'}
            },
            ido_classic: {
              human_name: "iDo'Classique",
              description: "Vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              label: 'Téléchargement + Pré-saisie comptable',
              price: 20,
              commitment: 0,
              data_flows: { max: 100, duration: 'month', excess_price: 0.25 },
              options: { upload: 'strict', bank: 'optional', scan: 'strict', mail: 'optional', digitize: 'optional', preassignment: 'optional'}
            },
            ido_micro: {
              human_name: "iDo'Micro",
              description: "Vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              label: 'Téléchargement + Pré-saisie comptable + Engagement 12 mois',
              price: 10,
              commitment: 12,
              data_flows: { max: 100, duration: 'annual', excess_price: 0.25 },
              options: { upload: 'strict', bank: 'strict', scan: 'strict', mail: 'optional', digitize: 'optional', preassignment: 'strict'}
            },
            ido_micro_plus: {
              human_name: "iDo'Micro",
              description: "Vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              label: 'Téléchargement + Pré-saisie comptable + Engagement 12 mois',
              price: 10,
              commitment: 12,
              data_flows: { max: 25, duration: 'month', excess_price: 0.3 },
              options: { upload: 'strict', bank: 'optional', scan: 'strict', mail: 'optional', digitize: 'optional', preassignment: 'strict'}
            },
            ido_nano: {
              human_name: "iDo'Nano",
              description: "Vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              label: 'Téléchargement + Pré-saisie comptable + Engagement 12 mois',
              price: 5,
              commitment: 12,
              data_flows: { max: 100, duration: 'annual', excess_price: 0.25 },
              options: { upload: 'strict', bank: 'optional', scan: 'strict', mail: 'optional', digitize: 'optional', preassignment: 'strict'}
            },
            ido_mini: {
              human_name: "iDo'Mini",
              description: "Vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              label: 'Téléchargement + Pré-saisie comptable + Engagement 12 mois',
              price: 10,
              commitment: 12,
              data_flows: { max: 100, duration: 'month', excess_price: 0.25 },
              options: { upload: 'strict', bank: 'none', scan: 'strict', mail: 'none', preassignment: 'optional'}
            },            
            ido_x: {
              human_name: "iDo'X",
              description: "Vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              label: 'Factur-X + Pré-saisie comptable',
              price: 5,
              commitment: 0,
              data_flows: { max: 0, duration: 'month', excess_price: 0.25 },
              options: { upload: 'none', bank: 'optional', scan: 'none', mail: 'none', preassignment: 'strict' }
            },            
            ido_retriever: {
              human_name: "Automate",
              description: "Vous permet de bénéficier des automates de récupération bancaires",
              hint: "",
              label: 'Récupération banque',
              price: 5,
              commitment: 0,
              data_flows: { max: 0, duration: 'month', excess_price: 0.25 },
              options: { upload: 'none', bank: 'strict', scan: 'optional', mail: 'none', digitize: 'optional', preassignment: 'strict'}
            },
            ido_digitize: {
              human_name: "Numérisation",
              description: "Vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "",
              price: 0,
              commitment: 0,
              data_flows: { max: 0, duration: 'month', excess_price: 0.25 },
              options: { upload: 'none', bank: 'none', scan: 'strict', mail: 'none', preassignment: 'strict'}
            },
            preassignment: {
              human_name: "Pré-affectation",
              price: 9, 
              label: 'Pré-saisie comptable active', 
            },
            mail: {
              human_name: "Courrier",
              price: 10, 
              label: 'Envoi par courrier A/R', 
            },
            bank_excess: { price: 2 },
            journal_excess: { price: 1 },
            reduced_retriever: { price: 3 },
          }.freeze

  class << self
    def human_name_of(package)
      BillingMod::Configuration::LISTS[package.to_sym][:human_name]
    end

    def label_of(package)
      BillingMod::Configuration::LISTS[package.to_sym][:label]
    end

    def options_of(package)
      BillingMod::Configuration::LISTS[package.to_sym][:options]
    end

    def price_of(package, user=nil)
      package = :reduced_retriever if package.to_s == 'ido_retriever' && CustomUtils.reduced_retriever_price?(user.try(:organization).try(:code)) #We have an exception of ido_retriever price

      BillingMod::Configuration::LISTS[package.to_sym][:price]
    end

    def flow_limit_of(package)
      BillingMod::Configuration::LISTS[package.to_sym][:data_flows][:max]
    end

    def excess_price_of(package)
      BillingMod::Configuration::LISTS[package.to_sym][:data_flows][:excess_price]
    end

    def excess_duration_of(package)
      BillingMod::Configuration::LISTS[package.to_sym][:data_flows][:duration]
    end

    def commitment_duration_of(package)
      BillingMod::Configuration::LISTS[package.to_sym][:commitment]
    end

    def discount_price(package, count, version=1)
      prices = {
                  '1' =>  [
                              { limit: (0..75), package_price: 0, retriever_price: 0 },
                              { limit: (76..150), package_price: -1, retriever_price: 0 },
                              { limit: (151..250), package_price: -1.5, retriever_price: -0.5 },
                              { limit: (251..350), package_price: -2, retriever_price: -0.75 },
                              { limit: (351..500), package_price: -3, retriever_price: -1 },
                              { limit: (501..Float::INFINITY), package_price: -4, retriever_price: -1.25 }
                          ],
                  '2' =>  [
                            { limit: (0..250), package_price: 0, retriever_price: 0 },
                            { limit: (251..Float::INFINITY), package_price: -10, retriever_price: 0 }
                          ],
                  '3' =>  [
                            { limit: (0..50), package_price: -1, retriever_price: 0 },
                            { limit: (51..150), package_price: -1.5, retriever_price: -0.5 },
                            { limit: (151..200), package_price: -2, retriever_price: -0.75 },
                            { limit: (201..250), package_price: -2.5, retriever_price: -1 },
                            { limit: (251..350), package_price: -3, retriever_price: -1.25 },
                            { limit: (351..500), package_price: -4, retriever_price: -1.50 },
                            { limit: (501..Float::INFINITY), package_price: -5, retriever_price: -2 }
                          ],
                         
               }

      _price = 0
      _found = false

      prices[version.to_s].each do |node|
        next if _found

        if ['ido_retriever', 'bank_option'].include?(package.to_s)
          _price = node[:retriever_price]  if node[:limit].include?(count)
        else
          _price = node[:package_price] if node[:limit].include?(count)
        end

        _found = true if _price < 0
      end

      _price
    end
  end
end