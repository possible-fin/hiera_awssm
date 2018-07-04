Puppet::Functions.create_function(:hiera_awssm) do

  begin
    require 'aws-sdk-secretsmanager'
  rescue LoadError
    raise Puppet::DataBinding::LookupError, '[hiera-awssm] Must install aws-sdk-secretsmanager to use hiera-awssm backend'
  end

  dispatch :lookup_key do
    param 'String[1]', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def lookup_key(key, options, context)
    unless options.key?('region')
      raise ArgumentError, 'hiera-awssm region must be specified in hiera.yaml.'
    end

    unless options.key?('sensitive')
      raise ArgumentError, 'hiera-awssm sensitive must be specified in hiera.yaml.'
    end

    confine_keys = options['confine_to_keys']

    if confine_keys
      raise ArgumentError, 'confine_to_keys must be an array in hiera.yaml' unless confine_keys.is_a?(Array)
      confine_keys.map! { |r| Regexp.new(r) }
      regex_key_match = Regexp.union(confine_keys)
      unless key[regex_key_match] == key
        context.explain { 'Skipping hiera-awssm backend because key does not match confine_to_keys' }
        return context.not_found
      end
    end

    begin
      client = Aws::SecretsManager::Client.new(
        region: options['region'],
        http_proxy: options['proxy_uri']
      )
      secret = client.get_secret_value(secret_id: key)

      return Puppet::Pops::Types::PSensitiveType::Sensitive.new(secret.secret_string) if options['sensitive']
      return secret.secret_string

    rescue Aws::SecretsManager::Errors::ResourceNotFoundException
      return context.not_found
    end
  end

end
