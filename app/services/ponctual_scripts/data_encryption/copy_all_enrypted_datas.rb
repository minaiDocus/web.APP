class PonctualScripts::DataEncryption::CopyAllEncryptedDatas
     ALL_MODELS = [
                    "Archive::BudgeaUser", "Box", "BridgeAccount", "BudgeaAccount", "DropboxBasic", "ExactOnline", "Ftp", "GoogleDoc", "Ibiza", "Knowings", "McfSettings",
                    "NewProviderRequest", "Organization", "Retriever", "Sftp", "Software::Acd", "Software::ExactOnline", "Software::Ibiza", "Software::MyUnisoft", "User"
                  ]

  def self.execute
    new().execute
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
end