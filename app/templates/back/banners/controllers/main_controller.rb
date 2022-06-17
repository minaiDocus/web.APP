# frozen_string_literal: true
class Admin::Banners::MainController < BackController
  prepend_view_path('app/templates/back/banners/views')

  def index
    @banner_images        = BannerImage.order(created_at: :desc)
    @current_banner_image = BannerImage.find_by(is_used: :true) || BannerImage.last
    if !@current_banner_image
      @current_banner_image = BannerImage.new
      @current_banner_image.path = "/assets/logo/tiny_logo_2.png"
      @current_banner_image.width = 272
      @current_banner_image.height = 120
      @current_banner_image.align = ':center'
      @current_banner_image.pos_x = 142
      @current_banner_image.pos_y = 1
    end
  end
  
  def edit    
  end

  def upload_file
    @banner_image = BannerImage.new
      
    if params[:banner_image_file].present?

      file_name = (DateTime.now.strftime('%Y%m%d%H%M%S') +'_' + params[:banner_image_file].original_filename)

      if Rails.env == "production"
        dir = CustomUtils.mktmpdir('banner_image', "/nfs/banner_image/", false)
        @banner_image.path = File.join(dir, file_name)
      else
        dir = File.join(Rails.root, 'app', 'assets', 'images', 'banner_images')
        FileUtils.mkdir_p(dir) unless File.exist?(dir) 
        @banner_image.path = File.join('/assets','images', 'banner_images', file_name)
      end

      file_path = File.join(dir, file_name)
      original_path = params[:banner_image_file].path

      FileUtils.cp original_path, file_path
        @banner_image.name = params[:name] if params[:name].present?

        if @banner_image.save
          flash[:success] = 'Image enregistrée avec succès.'
        else
          flash[:error] = "Erreur d'enregistrement."
        end
        redirect_to admin_banners_path
    end
  end

  def configure_image_properties
    @banner_id          = params[:banner_path_temp]
    @banner_path        = params[:banner_path]
    @banner_width       = params[:banner_width]
    @banner_height      = params[:banner_height]
    @banner_alignment   = params[:banner_alignment]
    @banner_pos_x       = params[:banner_pos_x ]
    @banner_pos_y       = params[:banner_pos_y]

    @other_orders       = { june_extra: 0, discount_price: 0, re_site_price: 0, orders_price: 0, digitize_price: 0, remaining_month_price: 0 }
    organization        = Organization.find 7; packages_count = { ido_classic: 4, ido_nano: 2, ido_x: 6, ido_micro: 8, mail: 3, ido_retriever: 8, ido_digitize: 4}; invoice = BillingMod::Invoice.last; total_customers_price = 4000
    time                = 1.months.ago
    customers_excess    = { bank_excess_count: 20, bank_excess_price: 20000, journal_excess_count: 10, journal_excess_price: 1440, excess_billing_count: 30, excess_billing_price: 7000 }
    other_orders        = { june_extra: 255520, discount_price: 225520, re_site_price: 25580, orders_price: 55850, digitize_price: 25220, remaining_month_price: 25250 }
    @invoice_path       = BillingMod::PdfGeneratorV2.new(organization, packages_count, invoice, total_customers_price, time, customers_excess, other_orders, @banner_path, @banner_width, @banner_height, @banner_alignment, @banner_pos_x, @banner_pos_y, true).generate
    if @invoice_path.present?
      flash[:success]   = 'Modèle de facture généré avec succès.'
      self.update(@banner_id) if @banner_id
    else
      flash[:error]     = "Erreur lors de la génération du modèle de facture."
    end
    redirect_to admin_banners_path
  end

  def update(banner_id)
    @banner_image_update          = BannerImage.find(banner_id)
    @banner_image_update.is_used  = true
    @banner_image_update.width    = @banner_width
    @banner_image_update.height   = @banner_height
    @banner_image_update.align    = @banner_alignment
    @banner_image_update.pos_x    = @banner_pos_x
    @banner_image_update.pos_y    = @banner_pos_y

    all_banner_image_where_is_used_equal_true = BannerImage.where(:is_used => true)

    all_banner_image_where_is_used_equal_true.each do |temp_banner_image|
      temp_banner_image.is_used   = false
      temp_banner_image.save
    end

    if @banner_image_update.save
      flash[:success]             = 'Les paramètres ont été bien enregistrés'
    else
      flash[:error]               = "Erreur d'enregistrement des paramètres"
      return
    end
  end

  def destroy
    @banner_image = BannerImage.find(params[:id])

#    @banner_image.destroy

    redirect_to admin_banners_path
  end

  def fetch_banner
    @banner_image_update = BannerImage.find(params[:id])
    render json: { banner_image_update: @banner_image_update }
  end

  def banner_params
    params.require(:banner_image).permit(:name, :path, :width, :height, :align, :pos_x, :pos_y)
  end

end