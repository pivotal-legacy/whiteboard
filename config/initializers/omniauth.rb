require 'omniauth'
idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
idp_metadata = idp_metadata_parser.parse_remote_to_hash(ENV["IDP_METADATA_XML_URL"])

Rails.application.config.middleware.use OmniAuth::Strategies::SAML,
    idp_metadata.merge(
        :issuer                         => ENV["WS1_AUDIENCE"]
    )

