# Generate a SepaDirectDebit CSV format to import in Slimpay
class BillingMod::SepaXmlDirectDebitGenerator
  def self.execute(invoice_time, debit_date)
    @debit_date = debit_date

    @period = CustomUtils.period_of(invoice_time.beginning_of_month - 1.month)

    @sdd = SEPA::DirectDebit.new(
      name:       'iDocus SAS',
      bic:        'CRLYFRPPXXX',
      iban:       'FR5630002022380000070756S92',
      creditor_identifier: 'FR12ZZZ660752'
    )

    @sdd.message_identification = "PRLVIDO#{Time.now.to_i}"

    data   = DebitMandate.configured.map do |debit_mandate|
      invoice = debit_mandate.organization.invoices.of_period(@period).where(
        "amount_in_cents_w_vat > 0").first
      invoice ? [debit_mandate, invoice] : nil
    end.compact

    data.each do |d|
      build_line(d)
    end

    @sdd.to_xml('pain.008.001.02')
  end

  private

  def self.build_line(d)
    @sdd.add_transaction(
      name:                      d[0].companyName || d[0].organization.name,
      bic:                       d[0].bic,
      iban:                      d[0].iban,
      amount:                    '%0.2f' % (d[1].amount_in_cents_w_vat / 100.0),
      currency:                  'EUR',
      reference:                 "iDocus - F#{d[1].number}",
      mandate_id:                d[0].RUM,
      mandate_date_of_signature: Date.parse(d[0].signatureDate),
      local_instrument: 'CORE',
      sequence_type: 'RCUR',
      requested_date: @debit_date,
      batch_booking: true
    )
  end
end
