class ExportPreseizures::MainController < FrontController
  prepend_view_path('app/templates/front/export_preseizures/views')

  def index

    params[:page]     = params[:page].presence || 1
    params[:per_page] = params[:per_page].presence || 20


    @filter_datas = { documents: [], journals: [], periods: [] }

    all_preassignment_exports = @user.pre_assignment_exports.where('DATE_FORMAT(created_at, "%Y%m%d") >= 20230216').where('created_at >= ?', 4.month.ago)
    #@preassignment_exports = @user.pre_assignment_exports

    @preassignment_exports = @preassignment_exports.where( params[:document_filter].map{ |dl| "pack_name LIKE '%#{ dl.gsub('%','\%') } %'" }.join(' OR ') ) if params[:document_filter].present?
    @preassignment_exports = @preassignment_exports.where( params[:journal_filter].map{ |jl| "pack_name LIKE '% #{jl} %'" }.join(' OR ') )                  if params[:journal_filter].present?
    @preassignment_exports = @preassignment_exports.where( params[:period_list].map{ |pl| "pack_name LIKE '% #{pl}%'" }.join(' OR ') )                      if params[:period_list].present?

    all_pack_name = @preassignment_exports.distinct.pluck(:pack_name).compact

      all_pack_name.each do |pack_name|
        @filter_datas[:documents] << pack_name.split(' ')[0]  if not @filter_datas[:documents].include?pack_name.split(' ')[0]
        @filter_datas[:journals] << pack_name.split(' ')[1]   if not @filter_datas[:journals].include?pack_name.split(' ')[1]
        @filter_datas[:periods] << pack_name.split(' ')[2]    if not @filter_datas[:periods].include?pack_name.split(' ')[2]

      end


    @preassignment_exports = @preassignment_exports.page(params[:page]).per(params[:per_page])
  end


  def download_export_preseizures
    preassignment_export_id = params["p"]
    preassignment_export = PreAssignmentExport.where(id: preassignment_export_id).first
    filepath = ''

    begin
      filepath = preassignment_export.cloud_content_object.path
    rescue StandardError => e
      filepath = ''
    end

    if File.exist?(filepath.to_s)
      mime_type = MIME::Types.type_for(filepath).first.content_type

      send_file(filepath, type: mime_type, filename: @preassignment_export.cloud_content_object.filename, disposition: 'attachment')
    else
      flash[:error] = 'Fichier inexistant'
      redirect_to export_preseizures_list_path
    end

  end

end