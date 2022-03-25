class Package::Pricing
  LISTS = {
            ido_classic: {
              human_name: "iDo'Classique",
              description: "Vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              price: 20,
              commitment: 0,
              data_flows: { max: 100, duration: 'month', excess_price: 0.25 },
              options: { upload: 'strict', bank: 'optional', scan: 'strict', preassignment: 'optional', mail: 'optional'}
            },
            ido_nano: {
              human_name: "iDo'Nano",
              description: "vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              price: 5,
              commitment: 12,
              data_flows: { max: 100, duration: 'annual', excess_price: 0.25 },
              options: { upload: 'strict', bank: 'none', scan: 'strict', preassignment: 'strict', mail: 'optional'}
            },
            ido_micro: {
              human_name: "iDo'Micro",
              description: "vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              price: 10,
              commitment: 12,
              data_flows: { max: 100, duration: 'annual', excess_price: 0.25 },
              options: { upload: 'strict', bank: 'strict', scan: 'strict', preassignment: 'strict', mail: 'optional'}
            },
            ido_micro_plus: {
              human_name: "iDo'Micro",
              description: "vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              price: 10,
              commitment: 12,
              data_flows: { max: 25, duration: 'month', excess_price: 0.3 },
              options: { upload: 'strict', bank: 'optional', scan: 'strict', preassignment: 'strict', mail: 'optional'}
            },
            ido_x: {
              human_name: "iDo'X",
              description: "vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "Au-delà du quota cabinet cumulé, calcul du dépassement simplifié : 0,25€ ht/facture",
              price: 5,
              commitment: 0,
              data_flows: { max: 0, duration: 'month', excess_price: 0.25 },
              options: { upload: 'none', bank: 'none', scan: 'none', preassignment: 'strict', mail: 'none'}
            },
            ido_retriever: {
              human_name: "Automate",
              description: "Vous permet de bénéficier des automates de récupération bancaires",
              hint: "",
              price: 5,
              commitment: 0,
              data_flows: { max: 0, duration: 'month', excess_price: 0.25 },
              options: { upload: 'none', bank: 'strict', scan: 'none', preassignment: 'strict', mail: 'none'}
            },
            ido_digitize: {
              human_name: "Numérisation",
              description: "vous permet de transférer jusqu'à 100 pièces/mois, mutualisation des quotas au niveau du cabinet.",
              hint: "",
              price: 0,
              commitment: 0,
              data_flows: { max: 0, duration: 'month', excess_price: 0.25 },
              options: { upload: 'none', bank: 'none', scan: 'strict', preassignment: 'strict', mail: 'none'}
            },
            preassignment: { price: 9 },
            mail: { price: 10 },
            bank_excess: { price: 2 },
            journal_excess: { price: 1 },
            reduced_retriever: { price: 3 },
          }.freeze

  class << self
    def human_name_of(package)
      Package::Pricing::LISTS[package.to_sym][:human_name]
    end

    def options_of(package)
      Package::Pricing::LISTS[package.to_sym][:options]
    end

    def price_of(package, user=nil)
      package = :reduced_retriever if package.to_s == 'ido_retriever' && CustomUtils.reduced_retriever_price?(user.try(:organization).try(:code)) #We have an exception of ido_retriever price

      Package::Pricing::LISTS[package.to_sym][:price]
    end

    def flow_limit_of(package)
      Package::Pricing::LISTS[package.to_sym][:data_flows][:max]
    end

    def excess_price_of(package)
      Package::Pricing::LISTS[package.to_sym][:data_flows][:excess_price]
    end

    def excess_duration_of(package)
      Package::Pricing::LISTS[package.to_sym][:data_flows][:duration]
    end

    def commitment_duration_of(package)
      Package::Pricing::LISTS[package.to_sym][:commitment]
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