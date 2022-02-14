# -*- encoding : UTF-8 -*-
class Billing::OrganizationExcess
  def initialize(period)
    @period          = period
    @organization    = period.organization
  end

  def execute
    get_basic_excess
    get_plus_micro_excess
  end

  private

  def get_basic_excess(hard_process = false)
    result = get_excess_of(:ido_classique, hard_process)

    @period.update({ basic_excess: result[:excess_compta_pieces], basic_total_compta_piece: result[:total_compta_pieces] })
  end

  def get_plus_micro_excess(hard_process = false)
    result = get_excess_of(:ido_plus_micro, hard_process)

    @period.update({ plus_micro_excess: result[:excess_compta_pieces], plus_micro_total_compta_piece: result[:total_compta_pieces] })
  end

  def get_excess_of(package, hard_process=false)
    return false if not @organization

    result = { excess_limit: 0, total_compta_pieces: 0 }

    customers_periods.each do |c_period|
      option = c_period.user.options
      valid  = (package.to_s == 'ido_classique')? valid_for_basic_quota(c_period) : valid_for_plus_micro_quota(c_period)

      if valid
        Billing::UpdatePeriodData.new(c_period).execute if hard_process

        if option.is_preassignment_authorized
          result[:excess_limit]        += c_period.max_preseizure_pieces_authorized.to_i
          result[:total_compta_pieces] += c_period.preseizure_pieces.to_i || 0
        end
      end
    end

    final  = { total_compta_pieces: 0, excess_compta_pieces: 0 }
    excess = result[:total_compta_pieces] - result[:excess_limit]

    if excess > 0
      final[:total_compta_pieces]  = result[:total_compta_pieces]
      final[:excess_compta_pieces] = excess
    end

    return final
  end

  def customers_periods
    return @customer_periods if @customer_periods

    time = @period.start_date.beginning_of_month + 15.days
    @customers_periods = Period.where(user_id: @organization.customers.active_at(time.to_date).map(&:id)).where('start_date <= ? AND end_date >= ?', time.to_date, time.to_date)
  end

  def valid_for_basic_quota(period)
    !period.is_package?('ido_plus_micro') && !period.is_package?('ido_micro') && !period.is_package?('ido_nano') && !period.is_package?('ido_mini')
  end

  def valid_for_plus_micro_quota(period)
    period.is_package?('ido_plus_micro')
  end
end