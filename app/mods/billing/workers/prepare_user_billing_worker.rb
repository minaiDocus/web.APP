class BillingMod::PrepareUserBillingWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: false

  def perform
    UniqueJobs.for 'BillingMod::PrepareUserBilling' do
      period = CustomUtils.period_of(Time.now)
      user_ids_preseizures  = Pack::Report::Preseizure.where('DATE_FORMAT(created_at, "%Y%m%d%H") >= ?', 7.hours.ago.strftime('%Y%m%d%H')).distinct.select(:user_id).pluck(:user_id)
      user_ids_pieces       = Pack::Piece.where('DATE_FORMAT(created_at, "%Y%m%d%H") >= ?', 7.hours.ago.strftime('%Y%m%d%H')).distinct.select(:user_id).pluck(:user_id)

      user_ids = (user_ids_preseizures + user_ids_pieces).uniq

      user_ids.each do |user_id|
       BillingMod::PrepareUserBilling.new(User.find(user_id), period).execute
      end
    end
  end
end
