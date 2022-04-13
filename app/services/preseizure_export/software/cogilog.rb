# -*- encoding : UTF-8 -*-
# Generates a ZIP to import in Cogiog
class PreseizureExport::Software::Cogilog
  def initialize(preseizures)
    @preseizures = preseizures
  end


  def execute
    base_name = @preseizures.first.report.name.tr(' ', '_').tr('%', '_')
    file_path = ''

    CustomUtils.mktmpdir('cogilog_export', nil, false) do |dir|
      PreseizureExport::Software::Cogilog.delay_for(6.hours).remove_temp_dir(dir)

      data = PreseizureExport::PreseizureToTxt.new(@preseizures).execute("cogilog") # Generate a txt with preseizures

      file_path = "#{dir}/#{base_name}.txt"
      File.open(file_path, 'w') do |f|
        f.write(data)
      end
    end

    file_path
  end


  def self.remove_temp_dir(dir)
    FileUtils.remove_entry dir if File.exist? dir
  end
end
