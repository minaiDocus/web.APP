class BillingMod::CreatePackage
  def initialize(user, package_name, options, apply_now = false)
    @user         = user
    @package_name = package_name
    @options      = options

    @my_package   = @user.my_package
    @apply_now    = (@my_package.present?)? apply_now : true

    @period      = CustomUtils.period_of(Time.now)
    @next_period = CustomUtils.period_of(1.month.after)
  end

  def execute
    return false if not @package_name

    @package_conf = BillingMod::Configuration::LISTS[@package_name.to_sym]

    if @apply_now || can_be_updated_now
      _period = @period
      @user.package_of(@next_period).try(:destroy)
    else
      _period = @next_period
    end

    package        = @user.package_of(_period) || BillingMod::Package.new
    package.user   = @user
    package.period = _period
    package.name   = @package_name

    package.preassignment_active = activate?(:preassignment)
    package.upload_active        = activate?(:upload)
    package.mail_active          = activate?(:mail)
    package.bank_active          = activate?(:bank)
    package.scan_active          = activate?(:scan)

    package.commitment_start_period = @my_package.try(:commitment_start_period).to_i
    package.commitment_end_period   = @my_package.try(:commitment_end_period).to_i

    if @package_conf[:commitment].to_i > 0 && (package.commitment_start_period.to_i == 0 || package.name != @my_package.try(:name))
      package.commitment_start_period = @period
      package.commitment_end_period   = CustomUtils.period_of(@package_conf[:commitment].to_i.month.after)
    elsif @package_conf[:commitment].to_i == 0
      package.commitment_start_period = 0
      package.commitment_end_period   = 0
    end

    package.save

    update_journal_size
  end

  private

  def _params(name)
   return @options[name.to_sym].present?
  end

  def activate?(option)
    @package_conf = BillingMod::Configuration::LISTS[@package_name.to_sym]
    options       = @package_conf[:options]

    if options[option.to_sym] == 'strict'
      return true
    elsif options[option.to_sym] == 'optional' && _params(option.to_sym)
      return true
    else
      return false
    end
  end

  def can_be_updated_now
    count = 0
    opts  = ['scan', 'preassignment', 'mail', 'bank']

    if @package_name == @my_package.try(:name)
      opts.each do |opt|
        count += 1 if not (@my_package.send("#{opt}_active".to_sym) == true && activate?(opt.to_sym) == false)
      end
    end

    return (count == opts.size)? true : false
  end

  def update_journal_size
    return false if @options['number_of_journals'].to_i < 5

    current_package = @user.package_of(@period)
    next_package    = @user.package_of(@next_period)
    journal_size    = 5
    user_journal_size = @user.account_book_types.size

    if user_journal_size < @options['number_of_journals'].to_i
      journal_size = @options['number_of_journals'].to_i
    else
      journal_size = user_journal_size
    end
    journal_size = 5 if journal_size < 5

    current_package.update(journal_size: journal_size) if current_package
    next_package.update(journal_size: journal_size)    if next_package
  end
end