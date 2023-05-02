# frozen_string_literal: true
class Admin::Invoices::MainController < BackController
  prepend_view_path('app/templates/back/invoices/views')

  before_action :load_invoice, only: %w[show update]

  # GET /admin/invoices
  def index
    @invoices = BillingMod::Invoice.search(search_terms(params[:invoice_contains])).order(sort_column => sort_direction)

    @invoices_count = @invoices.count

    @invoices = @invoices.page(params[:page]).per(params[:per_page])
  end

  # GET /admin/invoices/archive
  def archive
    file_path = BillingMod::ArchiveInvoice.archive_path(params[:file_name])

    if File.exist? file_path
      send_file(file_path, type: 'application/zip', filename: params[:file_name], x_sendfile: true)
    else
      raise ActionController::RoutingError, 'Not Found'
    end
  end

  # GET /admin/invoices/:id/download
  def download
    if params['invoice_ids'].present? && params['invoice_ids'].size <= 20
      zip_path = Billing::InvoicesToZip.new(params['invoice_ids']).execute

      if File.exist?(zip_path)
        send_data(File.read(zip_path), type: 'application/zip', filename: 'factures.zip', x_sendfile: true, disposition: 'inline')
      else
        flash[:error] = 'Aucune facture générée'
        redirect_to admin_invoices_index_path
      end
    elsif params['invoice_ids'].size > 20
      flash[:error] = 'Votre sélection dépasse le nombre maximum de fichiers téléchargeables recommandé (20 factures maximum).'
      redirect_to admin_invoices_index_path
    else
      flash[:error] = 'Aucune facture séléctionnée'
      redirect_to admin_invoices_index_path
    end
  end

  # POST /admin/invoices/debit_order
  def debit_order
    debit_date = begin
                  params[:debit_date].presence.to_date
                 rescue StandardError
                   Date.today
                end

    invoice_time = begin
                    params[:invoice_date].presence.to_time
                   rescue StandardError
                     Time.now
                  end

    @xml = BillingMod::SepaXmlDirectDebitGenerator.execute(invoice_time, debit_date)

    @filename = "order_#{invoice_time.strftime('%Y%m')}.xml"

    store_invoice_debit_order

    send_data(@xml, type: 'application/xml', filename: @filename)
  end

  # GET /admin/invoices/:id
  def show
    if File.exist?(@invoice.cloud_content_object.path.to_s)
      # type     = @invoice.content_content_type || 'application/pdf'
      # Find a way to get active record mime type
      type = 'application/pdf'
      filename = File.basename @invoice.cloud_content_object.path
      send_file(@invoice.cloud_content_object.path('', true), type: type, filename: filename, x_sendfile: true, disposition: 'inline')
    else
      render body: "Aucun fichier trouvé", status: :not_found
    end
  end

  private

  def load_invoice
    @invoice = BillingMod::Invoice.find(params[:id])
  end

  def sort_column
    params[:sort] || 'created_at'
  end
  helper_method :sort_column

  def sort_direction
    params[:direction] || 'desc'
  end
  helper_method :sort_direction

  def store_invoice_debit_order
    File.write(file_path, @xml)
  end

  def file_path
    File.join(invoice_dir, @filename)
  end

  def invoice_dir
    dir = "#{Rails.root}/files/invoices"
    FileUtils.makedirs(dir)
    FileUtils.chmod(0777, dir)
    dir
  end
end