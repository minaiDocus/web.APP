class ExportPreseizures::MainController < FrontController
  prepend_view_path('app/templates/front/export_preseizures/views')

  def index
    @preassignment_exports = @user.pre_assignment_exports.where('DATE_FORMAT(created_at, "%Y%m%d") >= 20230215')
    #@preassignment_exports = PreAssignmentExport.last 5
  end


  def download_export_preseizures
    preassignment_export_id = params["p"]
    preassignment_export = PreAssignmentExport.find(preassignment_export_id)
    filepath = ''

    begin
      filepath = preassignment_export.cloud_content_object.path
    rescue StandardError => e
      filepath = ''
    end

    if File.exist?(filepath.to_s)
      mime_type = ''

      if File.extname(filepath) == '.csv'
        mime_type = 'application/csv'
      elsif File.extname(filepath) == '.txt'
        mime_type = 'text/txt'
      elsif File.extname(filepath) == '.zip'
        mime_type = 'application/zip'
      elsif File.extname(filepath) == '.xls'
        mime_type = 'text/xls'
      elsif File.extname(filepath) == '.xml'
        mime_type = 'application/xml'
      else
      end
      #send_file(filepath, type: mime_type, filename: @preassignment_export.cloud_content_object.filename, x_sendfile: true, disposition: 'inline')
      send_file(filepath, type: mime_type, filename: @preassignment_export.cloud_content_object.filename, disposition: 'attachment')
    else
      flash[:error] = 'Fichier inexistant'
      redirect_to export_preseizures_list_path
    end

  end

end