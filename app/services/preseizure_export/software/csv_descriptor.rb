# -*- encoding : UTF-8 -*-
class PreseizureExport::Software::CsvDescriptor
  def initialize(preseizures, tmp_dir=nil, _format='csv')
    @preseizures = preseizures
    @user        = preseizures.first.user
    @dir         = tmp_dir.presence || CustomUtils.mktmpdir('csv_descriptor')

    @format      = _format
  end

  def execute
    return 'not_authorized' if not @user.uses?(:csv_descriptor)

    @base_name = @preseizures.first.report.name.tr(' ', '_').tr('%', '_')
    @file_path = "#{@dir}/#{@base_name}.csv"

    File.open(@file_path, 'w'){ |file| file.write(datas) }

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

    lines.join("\n")
  end

  def descriptor
    return @descriptor if @descriptor

    if @user.try(:csv_descriptor).try(:use_own_format?)
      @descriptor = @user.csv_descriptor!
    else
      @descriptor = @user.organization.csv_descriptor!
    end
  end

  def format_line(entry)
    line = ''

    descriptor.directive_to_a.each do |part|
      result = case part[0]
        when /\Adate\z/
          format = part[1].presence || "AAAA/MM/JJ"
          format.gsub!(/AAAA/, "%Y")
          format.gsub!(/AA/, "%y")
          format.gsub!(/MM/, "%m")
          format.gsub!(/JJ/, "%d")
          entry.preseizure.date.try(:strftime, format) || ''
        when /\Aperiod_date\z/
          format = part[1].presence || "AAAA/MM/JJ"
          format.gsub!(/AAAA/, "%Y")
          format.gsub!(/AA/, "%y")
          format.gsub!(/MM/, "%m")
          format.gsub!(/JJ/, "%d")
          res = entry.preseizure.date < entry.preseizure.period_date || entry.preseizure.date > entry.preseizure.end_period_date rescue true
          if res
            entry.preseizure.period_date.try(:strftime,format) || ''
          else
            entry.preseizure.date.try(:strftime, format) || ''
          end
        when /\Adeadline_date\z/
          format = part[1].presence || "AAAA/MM/JJ"
          format.gsub!(/AAAA/, "%Y")
          format.gsub!(/AA/, "%y")
          format.gsub!(/MM/, "%m")
          format.gsub!(/JJ/, "%d")
          entry.preseizure.deadline_date.try(:strftime, format) || ''
        when /\Aclient_code\z/
          part[1].to_i > 0 ? entry.preseizure.report.user.code[0, part[1].to_i] : entry.preseizure.report.user.code
        when /\Ajournal\z/
          part[1].to_i > 0 ? entry.preseizure.journal_prefered_name(:name)[0, part[1].to_i] : entry.preseizure.journal_prefered_name(:name)
        when /\Apseudonym\z/
          part[1].to_i > 0 ? entry.preseizure.journal_prefered_name(:pseudonym)[0, part[1].to_i] : entry.preseizure.journal_prefered_name(:pseudonym)
        when /\Aperiod\z/
          entry.preseizure.piece_name.try(:split).try(:[], 2)
        when /\Apiece_number\z/
          entry.preseizure.piece_name.try(:split).try(:[], 3).try(:to_i)
        when /\Aoriginal_piece_number\z/
          part[1].to_i > 0 ? entry.preseizure.piece_number[0, part[1].to_i] : entry.preseizure.piece_number
        when /\Apiece\z/
          part[1].to_i > 0 ? entry.preseizure.piece_name.try(:gsub, ' ', '_')[0, part[1].to_i] : entry.preseizure.piece_name.try(:gsub, ' ', '_')
        when /\Aoriginal_amount\z/
          "#{entry.preseizure.amount}".gsub(/[\.,\,]/, descriptor.separator)
        when /\Acurrency\z/
          "#{entry.preseizure.currency}".gsub(/[\.,\,]/, descriptor.separator)
        when /\Aconversion_rate\z/
          conversion_rate = "%0.3f" % entry.preseizure.conversion_rate rescue ""
          "#{conversion_rate}".gsub(/[\.,\,]/, descriptor.separator)
        when /\Apiece_url\z/
          if @user.is_access_by_token_active
            Settings.first.inner_url + entry.preseizure.piece.try(:get_access_url)
          else
            Settings.first.inner_url + entry.preseizure.piece_content_url
          end
        when /\Aremark\z/
          part[1].to_i > 0 ? entry.preseizure.observation[0, part[1].to_i] : entry.preseizure.observation
        when /\Athird_party\z/
          part[1].to_i > 0 ? entry.preseizure.third_party[0, part[1].to_i] : entry.preseizure.third_party
        when /\Anumber\z/
          entry.account.number
        when /\Adebit\z/
          "#{entry.get_debit}".gsub(/[\.,\,]/, descriptor.separator)
        when /\Acredit\z/
          "#{entry.get_credit}".gsub(/[\.,\,]/, descriptor.separator)
        when /\Acomplete_unit\z/
          entry.preseizure.unit.try(:upcase)
        when /\Apartial_unit\z/
          entry.preseizure.unit.split(//).try(:first).try(:upcase)
        when /\Aoperation_label\z/
          part[1].to_i > 0 ? entry.preseizure.operation_label.try(:[], [0, part[1].to_i]) : entry.preseizure.operation_label
        when /\Alettering\z/
          part[1].to_i > 0 ? entry.account.lettering[0, part[1].to_i] : entry.account.lettering
        when /\Atags\z/
          entry.preseizure.piece.get_tags
        when /\Aother\z/
          part[1].nil? ? '' : part[1]
        when /\Aseparator\z/
          ';'
        when /\Aspace\z/
          ' '
        else ''
      end

      line += result.to_s
    end

    line
  end
end
