class BillingMod::PrepareBillingsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: false

  def perform
    UniqueJobs.for 'BillingMod::PrepareBillings' do
      period = CustomUtils.period_of(Time.now)

      # jump_count = 0
      # Organization.billed.order(code: :asc) do |organization|
      #   billing = organization.billings.of_period(period).first
      #   next if billing && billing.updated_at <= 3.hours.ago
      #   next if jump_count > 3

      #   jump_count += 1

      #   organization.customers.active_at(Time.now.end_of_month + 1.day).each do |customer|
      #     next if not customer.can_be_billed?

      #     billing = customer.billings.of_period(period).first
      #     next if billing && billing.updated_at <= 3.hours.ago

      #     BillingMod::PrepareUserBilling.new(customer).execute
      #   end

      #   BillingMod::PrepareOrganzationBilling.new(organization).execute
      # end

      user_ids_preseizures  = Pack::Report::Preseizure.where('DATE_FORMAT(created_at, "%Y%m%d%H") >= ?', 7.hours.ago.strftime('%Y%m%d%H')).distinct.select(:user_id).pluck(:user_id)
      user_ids_pieces       = Pack::Piece.where('DATE_FORMAT(created_at, "%Y%m%d%H") >= ?', 7.hours.ago.strftime('%Y%m%d%H')).distinct.select(:user_id).pluck(:user_id)

      user_ids = (user_ids_preseizures + user_ids_pieces).uniq

      user_ids.each do |user_id|
       BillingMod::PrepareUserBilling.new(User.find(user_id), period).execute
      end
    end
  end
end
