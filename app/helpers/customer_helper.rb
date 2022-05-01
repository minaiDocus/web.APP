# -*- encoding : UTF-8 -*-

module CustomerHelper
  def popover_content(package)
    contents  = content_tag :h6, 'Abonnement actuel', class: 'popover-title text-center semibold p-2'    
    contents += content_tag :hr, '', class: 'm-1'

    count_price = 0

    if package
      %w(name preassignment mail bank scan).each do |column|
        next if BillingMod::Configuration.options_of(package.name)[column.to_sym] == 'strict'

        _column = column != 'name' ? column.to_s +  '_active' : column

        if package.send("#{_column}".to_sym)
          column = 'ido_retriever' if column == 'bank'
          column = 'ido_digitize'  if column == 'scan'
          column = package.name    if column == 'name'

          content      = ''
          content_span = ''

          price  = BillingMod::Configuration.price_of(column.to_sym).to_i     
          price -= BillingMod::Configuration.price_of(:preassignment).to_i if column == 'ido_classic' && package.name == 'ido_classic' && !package.preassignment_active

          content_span  += content_tag :span, BillingMod::Configuration.human_name_of(column), class: 'semibold float-start'
          content_span  += content_tag :span, price.to_s + '€', class: 'semibold float-end'
          content       += content_tag :div, content_span.html_safe, class: 'clearfix'

          if BillingMod::Configuration.label_of(column).present?
            content += content_tag :i, BillingMod::Configuration.label_of(column), class: 'clearfix'
          end
          content += content_tag :hr, '', class: 'm-1'

          contents += content_tag :div, content.html_safe, class: 'clearfix'

          count_price += price.to_i
        end
      end
    end

    contents += content_tag :hr, '', class: 'm-1'
    contents += content_tag :span, count_price.to_s + '€', class: 'semibold float-end p-1'

    content_tag :div, contents.html_safe, class: 'w-100'  
  end
end