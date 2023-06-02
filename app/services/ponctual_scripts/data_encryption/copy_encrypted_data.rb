class PonctualScripts::DataEncryption::CopyEncryptedData
  def self.execute(model)
    new(model).execute
  end

  def initialize(model)
    @model = model
    @column_name_array = []
  end


  def execute
    begin
      @model.columns.map(&:name).each do |column|
        if column.start_with?("encrypted_")
          real_column_name = column.gsub('encrypted_', '')
          @column_name_array << real_column_name
        end
      end

      if @column_name_array.size > 0
        copy_values(@column_name_array, @model)
      else
        puts "Aucune colonne de type 'encrypted' trouvée dans la table #{@model.table_name}."
        return false
      end

    rescue Exception => e
      puts e.message
      return false
    end

    puts "Copie de #{@model} terminée."
    return true
  end

  private

  def copy_values(list_column, model)
    total_records = model.count
    model.all.each_with_index do |record, index|
      puts "[#{model.table_name}] - Copie en cours : #{index + 1}/#{total_records}"

      list_column.each do |column|
        if record.respond_to?(column) && record.send(column.to_sym).present?
          record.send( "alpha_#{column}=".to_sym, record.send(column.to_sym) )                   #alpha
          record.send( "beta_#{column}=".to_sym, Base64.encode64(record.send(column.to_sym).to_s) )   #beta
        end
      end
      
      puts record.errors.messages if not record.save

      remaining_datas = total_records - index - 1
      puts "Nombre d'enregistrements restants pour #{model}: #{remaining_datas}"

      sleep(2) if index % 500000
    end
  end
end