require 'omniauth'

def get_idp_metadata
  if Rails.env.test?
    {}
  else
    idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
    idp_metadata_parser.parse_remote_to_hash(ENV["IDP_METADATA_XML_URL"])
  end
end


Rails.application.config.middleware.use OmniAuth::Strategies::SAML,
                                        get_idp_metadata.merge(
                                            :issuer => ENV["WS1_AUDIENCE"]
                                        )
