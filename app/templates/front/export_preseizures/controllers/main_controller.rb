class ExportPreseizures::MainController < FrontController
  prepend_view_path('app/templates/front/export_preseizures/views')

  def index
    @preassignment_exports = @user.pre_assignment_exports.where('DATE_FORMAT(created_at, "%Y%m%d") >= 20230216').where('created_at >= ?', 4.month.ago)
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