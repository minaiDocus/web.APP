class ChangeRawPreseizureToLongtextOnPackReportTempPreseizures < ActiveRecord::Migration[5.2]
  def change
    change_column :pack_report_temp_preseizures, :raw_preseizure, :longtext
  end
end
