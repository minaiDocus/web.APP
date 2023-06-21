class PonctualScripts::DataEncryption::CopyAllEncryptedDatas
     ALL_MODELS = [
                    "Archive::BudgeaUser", "Box", "BridgeAccount", "BudgeaAccount", "DropboxBasic", "ExactOnline", "Ftp", "GoogleDoc", "Ibiza", "Knowings", "McfSettings",
                    "NewProviderRequest", "Organization", "Retriever", "Sftp", "Software::Acd", "Software::ExactOnline", "Software::Ibiza", "Software::MyUnisoft"
                  ]

  def self.execute
    new().execute
  end

  def self.verify
    new().verify
  end

  def initialize
  end


  def execute
    puts '========================execute=========================='

    ALL_MODELS.each do |model_string|
      model = model_string.constantize
      puts model

      PonctualScripts::DataEncryption::CopyEncryptedData.execute(model)
    end

    return true
  end

  def verify
    ALL_MODELS.each do |model_string|
      model = model_string.constantize
      column_name_array = []

      begin
        model.columns.map(&:name).each do |column|
          if column.start_with?("encrypted_")
            real_column_name = column.gsub('encrypted_', '')
            column_name_array << real_column_name
          end
        end

        if column_name_array.size > 0
          col = column_name_array.first
          encrypted_size = model.where("encrypted_#{col} IS NOT NULL AND encrypted_#{col} <> ''").size
          alpha_size = model.where("alpha_#{col} IS NOT NULL AND alpha_#{col} <> ''").size

          puts "#{model_string} : Name: #{col} | Encrypted : #{encrypted_size} | Alpha : #{alpha_size}"
        else
          puts "Aucune colonne de type 'encrypted' trouvée dans la table #{@model.table_name}."
          return false
        end

      rescue Exception => e
        puts e.message
        return false
      end
    end; nil

    true
  end
end