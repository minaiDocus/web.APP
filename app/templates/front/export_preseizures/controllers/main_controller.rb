class ExportPreseizures::MainController < FrontController
  prepend_view_path('app/templates/front/export_preseizures/views')

  def index
    @preassignment_exports = @user.pre_assignment_exports
    #@preassignment_exports = PreAssignmentExport.last 5
  end


  def download_export_preseizures
    
    preassignment_export_id = params["q"]
    preassignment_export = PreAssignmentExport.find(preassignment_export_id)
    send_data(preassignment_export.cloud_content_object.path, disposition: 'attachment')


  end

end