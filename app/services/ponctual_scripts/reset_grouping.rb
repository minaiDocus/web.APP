class PonctualScripts::ResetGrouping
  def initialize; end

  private

  def execute
    pack_names = TempDocument.where(state: 'bundle_needed').collect(&:temp_pack).collect(&:name).uniq

    staffings = []
    pack_names.each do |p_name|
      name = p_name.split('%')[1].presence || p_name
      name = name.gsub(' all', '')
      sf = StaffingFlow.where("params LIKE '%#{name}%'").last
      staffings << sf if sf
    end

    p "Reset : #{ pack_names }"

    staffings.each{ |st| st.update(state: "ready")  if not st.processing? }

    p "Done : #{ staffings.size }"
  end
end

