module BrandHelper
  def brand_name_from_request(request)
    if request.env["SERVER_NAME"].include?("axelium")
      'Axelium'
    elsif request.env["SERVER_NAME"].include?('dkpartners')
      'DK Partners'
    else
      'iDocus'
    end
  end
end