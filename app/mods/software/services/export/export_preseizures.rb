###IMPORTANT : FOR NOW, EXPORT ONLY SUPPORT PRESEIZURES OF SAME REPORT.
class SoftwareMod::Export::Preseizures
  def self.execute(software, preseizures_ids, include_pieces=false, _format=nil, retry_count=0, requester_id=0)
    if retry_count <= 3
      preseizures = Pack::Report::Preseizure.where(id: preseizures_ids)

      new(software, _format).execute(preseizures, include_pieces, retry_count, requester_id) if preseizures.size > 0
    end
  end

  def initialize(software, _format=nil)
    @dir_path   = CustomUtils.mktmpdir('export')
    @software   = software
    @format     = _format
  end

  def execute(preseizures=[], include_pieces=false, retry_count=0, requester_id=0)
    #TO DO: Add ibiza export
    return 'not_authorized' if @software == 'ibiza'

    @requester  = User.where(id: requester_id).first

    @preseizures = Array(preseizures).sort_by{|e| e.position }

    @abort_and_retry_later = false
    @retry_count           = retry_count

    @software_class = nil
    @file_path      = ''
    @include_pieces = include_pieces
    @report         = @preseizures.first.report

    sub_pieces_dir  = nil
    result          = 'not_authorized'

    case @software
    when 'csv_descriptor'
      @software_class = SoftwareMod::Export::CsvDescriptor
    when 'coala'
      @software_class = SoftwareMod::Export::Coala
    when 'cegid'
      @software_class = SoftwareMod::Export::Cegid
    when 'quadratus'
      @software_class = SoftwareMod::Export::Quadratus
    when 'fec_acd'
      @software_class = SoftwareMod::Export::FecAcd
    when 'cogilog'
      @software_class = SoftwareMod::Export::Cogilog
    when 'ciel'
      @software_class = SoftwareMod::Export::Ciel
    when 'fec_agiris'
      @software_class = SoftwareMod::Export::FecAgiris
    end

    begin
      result = @software_class.new(@preseizures, @dir_path, @format).execute
    rescue => e
      result = e.to_s
    end
    @file_path = result

    if @file_path != 'not_authorized'
      if @include_pieces && File.exist?(@file_path.to_s)
        copy_pieces_files(sub_pieces_dir)

        if @abort_and_retry_later
          retry_later
          return nil
        end

        @file_path = zip_dir
      end

      create_preassignment_export

      if File.exist?(@file_path.to_s)
        @export.got_success(@file_path)

        send_success_email
      else
        @export.got_error(@file_path.presence || 'Internal server error')
      end
    end

    @file_path
  end

  private

  def copy_pieces_files(sub_pieces_dir = nil)
    pieces = Pack::Piece.unscoped.where(id: @preseizures.collect(&:piece_id))

    pieces.each do |piece|
      next if @abort_and_retry_later

      piece_path = piece.cloud_content_object.reload.path
      next if not piece_path

      if not DocumentTools.modifiable?(piece_path)
        @abort_and_retry_later = true
        next
      end

      ############# PIECE FILENAME STRUCTURE IS DEFINE IN SOFTWARE CLASS TARGET (width : self.file_name_format) #########################
      file_name = @software_class.respond_to?(:file_name_format) ? @software_class.file_name_format(piece) : File.basename(piece_path)
      final_dir = @dir_path

      if sub_pieces_dir
        final_dir = @dir_path + '/' + sub_pieces_dir
        FileUtils.mkdir_p final_dir
        FileUtils.chmod(0777, final_dir)
      end

      FileUtils.cp piece_path, "#{final_dir}/#{file_name}" 
    end
  end

  def zip_dir
    zip_name = "export_#{@software}_#{Time.now.strftime('%Y%m%d_%H%M')}.zip"
    zip_path = "#{@dir_path}/#{zip_name}"

    Dir.chdir @dir_path
    POSIX::Spawn.system "zip #{zip_name} *"

    zip_path
  end

  def create_preassignment_export
    @export                = PreAssignmentExport.new

    @export.report         = @report
    @export.for            = @software
    @export.user           = @report.user
    @export.organization   = @report.organization
    @export.pack_name      = @report.name
    @export.total_item     = @preseizures.size
    @export.preseizures    = @preseizures

    @export.save
  end

  def retry_later
    if @retry_count <= 3
      SoftwareMod::Export::Preseizures.delay_for(1.hours).execute(@software, @preseizures.collect(&:id), @include_pieces, @format, (@retry_count + 1), @requester.try(:id))
    else
      send_error_email
    end
  end

  def send_error_email
    ExportPreseizuresMailer.notify_failure(@requester).deliver if @requester
  end

  def send_success_email
    ExportPreseizuresMailer.notify_success(@requester).deliver if @requester
  end
end