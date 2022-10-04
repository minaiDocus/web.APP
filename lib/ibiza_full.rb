class IbizaFullLib
  def initialize(software=nil)
    @domain        = IbizaFullConf.domain
    @client_id     = IbizaFullConf.client_id
    @client_secret = IbizaFullConf.client_secret

    @software      = software
    @access_token  = software.try(:access_token)
  end

  def get_authorization_url
    @domain.to_s + '/oauth2/authorize'
  end

  def request_auth_token(code=nil)
    response = send_request('/cred/oauth2/token', no_auth_headers, 'POST', { grant_type: 'authorization_code', client_id: @client_id, client_secret: @client_secret, code: code } )

    set_tokens_with(response)
  end

  def refresh_access_token
    response = send_request('/cred/oauth2/token', no_auth_headers, 'POST', { grant_type: 'refresh_token', client_id: @client_id, client_secret: @client_secret, refresh_token: @software.try(:refresh_token) })

    set_tokens_with(response)
  end

  def get_journals
    uri      = '/accounting/v1/books'
    response = send_request(uri, nil, 'GET')
    response.try(:[], 'body').try(:[], "_embedded").try(:[], "books").presence || []
  end

  def get_counterparts_of(account_number, journal)
    uri      = "/accounting/v1/accounts/#{account_number}/counterparts/#{journal}"
    response = send_request(uri, nil, 'GET')
    response.try(:[], 'body').try(:[], "counterparts").presence || []
  end

  private

  def validate_token
    refresh_access_token if @software && (!@software.token_expires_in || @software.token_expires_in < 15.minutes.ago)
  end

  def set_tokens_with(response)
    if @software
      @access_token = response.access_token

      @software.access_token      = response.access_token
      @software.token_expires_in  = response.expires_in
      @software.access_token_2    = response.refresh_token

      @software.save
    end
  end

  def no_auth_headers
    {
      'Authorization' => nil,
      'X-Company' => nil
    }
  end

  def default_headers
    {
      'Authorization' => "Bearer #{@access_token}",
      'X-Company' => 295399,
      'Content-Type' => 'application/json'
    }
  end

  def send_request(url, headers=nil, method='GET', body=nil)
    __headers = default_headers.merge(headers.presence || {}).compact.with_indifferent_access
    
    if __headers['Authorization'].present?
      validate_token
      __headers['Authorization'] = @access_token
    end

    base_uri   = @domain.to_s + url.to_s

    connection = Faraday.new(:url => base_uri, request: { timeout: 180 }) do |f|
      f.response :logger
      f.request :oauth2, 'token', token_type: :bearer
      f.adapter Faraday.default_adapter
    end

    begin
      response = connection.run_request(method, base_uri, body, __headers)
    rescue => e
      System::Log.info('ibiza', "[Ibiza][Error] - #{base_uri.to_s} => #{e.to_s}")
      response = OpenStruct.new({ headers: { 'Content-Type' => 'none' }, custom_error_message: 'can not establish connection' })
    end

    response
  end
end