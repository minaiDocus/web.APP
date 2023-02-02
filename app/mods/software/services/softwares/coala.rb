# -*- encoding : UTF-8 -*-
class SoftwareMod::Service::Coala
  def initialize(preseizures, tmp_dir=nil, _format='csv')
    @preseizures = preseizures
    @user        = preseizures.first.user
    @dir         = tmp_dir.presence || CustomUtils.mktmpdir('coala_export')

    @format      = _format
  end

  def execute
    return 'not_authorized' if not @user.uses?(:coala)

    @base_name = @preseizures.first.report.name.tr(' ', '_').tr('%', '_')
    @file_path = ''

    if @format == 'xls'
      @file_path = to_xls
    else
      @file_path = to_csv
    end

    @file_path
  end

  private

  def datas
    lines = []

    @preseizures.each do |preseizure|
      preseizure.entries.by_position.each do |entry|
        lines << format_line(entry)
      end
    end

    lines
  end

  def format_line(entry)
    fifth_column = entry.preseizure.third_party || entry.preseizure.operation_label
    if ['NSA'].include?(entry.preseizure.organization.code)
      fifth_column = [entry.preseizure.third_party, entry.preseizure.piece_number].join(' ')
    else
      fifth_column = [fifth_column, entry.preseizure.piece_number].join(' - ')
    end

    result =  [
                entry.preseizure.computed_date.try(:strftime, "%d/%m/%Y"),
                entry.preseizure.journal_name.downcase,
                entry.account.number,
                entry.preseizure.coala_piece_name,
                fifth_column,
                "#{entry.get_debit}".gsub(/[\.,\,]/, '.'),
                "#{entry.get_credit}".gsub(/[\.,\,]/, '.'),
                "E"
              ].join(';')

    result.to_s
  end

  def to_xls
    file_path = "#{@dir}/#{@base_name}.xls"
    xls_data = []

    datas.each do |d|
      xls = d.split(';')
      tmp_data = {}
      xls.each_with_index do |o, i|
        tmp_data["field_#{i.to_s}".to_sym] = o
      end
      xls_data << OpenStruct.new(tmp_data)
    end

    ToXls::Writer.new(xls_data, columns: [:field_0, :field_1, :field_2, :field_3, :field_4, :field_5, :field_6, :field_7], headers: false).write_io(file_path)

    file_path
  end

  def to_csv
    file_path = "#{@dir}/#{@base_name}.csv"

    file = File.open(file_path, 'w')
    file.write(datas.join("\n"))
    file.close

    file_path
  end
end
