# -*- encoding : UTF-8 -*-

module CustomerHelper
  def popover_content(period_option=nil)
    contents = content_tag :h6, 'Abonnement actuel', class: 'popover-title text-center semibold p-2'    
    contents += content_tag :hr, '', class: 'm-1' 

    count_price = 0

    if period_option
      period_option.each_with_index do |option, index|        
        content = ''
        content_span = ''
        count_price += option.price_in_cents_wo_vat * 0.01

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
    end
    content_tag :div, contents.html_safe, class: 'w-100'   
  end
end