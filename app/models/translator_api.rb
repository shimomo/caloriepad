class TranslatorApi
  include ActiveModel::Model

  def initialize(ocp_apim_subscription_key)
    @access_tokne = authenticate(ocp_apim_subscription_key)
  end

  def authenticate(ocp_apim_subscription_key)
    uri = URI.parse("https://api.cognitive.microsoft.com/sts/v1.0/issueToken")
    request = Net::HTTP::Post.new(uri.request_uri)
    request["Ocp-Apim-Subscription-Key"] = ocp_apim_subscription_key
    request.body = {}.to_json
    response = generate_https(uri).request(request)
    response.body
  end

  def to_english(text)
    uri = URI.parse("https://api.microsofttranslator.com/V2/Http.svc/Translate")
    uri.query = URI.encode_www_form(generate_params(text))
    request = Net::HTTP::Get.new(uri.request_uri)
    request["Authorization"] = "Bearer #{@access_tokne}"
    response = generate_https(uri).request(request)
    ApplicationController.helpers.strip_tags(response.body)
  end

  private

  def generate_params(text)
    params = Hash.new
    params.store("text", text)
    params.store("to", "en")
    params
  end

  def generate_https(uri)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https
  end
end
