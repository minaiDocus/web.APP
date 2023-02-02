# -*- encoding : UTF-8 -*-
class SoftwareMod::Service::Quadratus
  def self.file_name_format(piece)
    piece.position.to_s + '.pdf'
  end

  def initialize(preseizures, tmp_dir=nil, _format='txt')
    @preseizures = preseizures
    @user        = preseizures.first.user
    @dir         = tmp_dir.presence || CustomUtils.mktmpdir('quadratus')

    @format      = _format
  end

  def execute
    return 'not_authorized' if not @user.uses?(:quadratus)

    @base_name = @preseizures.first.report.name.tr(' ', '_').tr('%', '_')
    @file_path = "#{@dir}/#{@base_name}.txt"

    File.open(@file_path, 'w'){ |file| file.write(datas) }

    @file_path
  end

  private

  def datas
    data = []

    @preseizures.each do |preseizure|
      preseizure.accounts.order(type: :asc).each do |account|
        entry = account.entries.first

        next if entry.amount.to_f == 0

        if preseizure.operation
          label = preseizure.operation_label.strip[0..29]
        else
          label = [preseizure.third_party.presence, preseizure.piece_number.presence].compact.join(' - ').strip[0..29]
        end

        label = ' ' unless label.present?
        line = ' ' * 256
        line[0] = 'M'
        account_number = entry.account.try(:number) || ''

        8.times do |i|
          line[i + 1] = account_number[i] || ' '
        end

        line[9..10]    = preseizure.journal_name[0..1]
        line[11..13]   = '000'
        line[14..19]   = preseizure.computed_date.strftime('%d%m%y') if preseizure.date
        line[20]       = 'F' if CustomUtils.use_vats_2?(preseizure.organization.code)

        e = 21 + label[0..19].size - 1

        line[21..e]    = label[0..19]
        line[41]       = entry.type == 1 ? 'D' : 'C'
        line[42]       = entry.amount.to_f >= 0.0 ? '+' : '-'
        line[43..54]   = '%012d' % entry.amount_in_cents.to_f
        line[63..68]   = preseizure.deadline_date.strftime('%d%m%y') if preseizure.deadline_date
        line[69..73]   = entry.account.lettering.strip[0..4]         if entry.account.lettering.present?
        line[74..78]   = preseizure.piece_number.strip[0..4]         if preseizure.piece_number.present?
        line[99..106]  = preseizure.piece_number.strip[0..7]         if preseizure.piece_number.present?
        line[107..109] = CustomUtils.use_vats_2?(preseizure.organization.code) ? 'FRF' : 'EUR'
        line[110..112] = preseizure.journal_name.strip[0..2]         if preseizure.journal_name.strip.size > 2

        if label.size > 20
          e = 116 + label.size - 1
          line[116..e] = label
        end

        line[148..157] = preseizure.piece_number.strip[0..9].rjust(10, '0') if preseizure.piece_number.present?

        if preseizure.piece
          file_name = SoftwareMod::Service::Quadratus.file_name_format(preseizure.piece)
          e = 181 + file_name.size - 1
          line[181..e] = file_name
        end

        data << line

      end
    end

    data.join("\n")
  end
end
