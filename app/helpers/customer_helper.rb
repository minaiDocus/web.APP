# -*- encoding : UTF-8 -*-

module CustomerHelper
  def popover_content(package)
    contents = content_tag :h6, 'Abonnement actuel', class: 'popover-title text-center semibold p-2'    
    contents += content_tag :hr, '', class: 'm-1'

    count_price = 0

    debugger

    if package            
      content = ''
      content_span = ''
      count_price += BillingMod::Configuration.price_of(package)

      content_span += content_tag :span, option.group_title, class: 'semibold float-start'
      content_span += content_tag :span, (option.price_in_cents_wo_vat * 0.01).to_s + '€', class: 'semibold float-end'
      content += content_tag :div, content_span.html_safe, class: 'clearfix'

      if option.title.present?
        content += content_tag :i, option.title, class: 'clearfix'                 
      end

      contents += content_tag :div, content.html_safe, class: 'p-2'
      contents += content_tag :hr, '', class: 'm-1' 

      if index == period_option.size - 1
        contents += content_tag :span, count_price.to_s + '€', class: 'semibold float-end p-1'
      end
    end
    content_tag :div, contents.html_safe, class: 'w-100'   
  end
end