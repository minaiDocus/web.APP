class ExportPreseizures::MainController < FrontController
  prepend_view_path('app/templates/front/export_preseizures/views')

  def index
    #@preassignment_export = PreAssignmentExport.find(params[:id])
    #ids = @user.accounts.ids
    @preassignment_exports = PreAssignmentExport.last 5
  end

end