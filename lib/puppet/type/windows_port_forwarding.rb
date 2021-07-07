require 'puppet/parameter/boolean'

Puppet::Type.newtype(:windows_port_forwarding) do
  @doc = 'Manage Windows Port Forwarding with Puppet'

  ensurable do
    desc 'How to ensure this port forwarding (`present` or `absent`)'
    defaultvalues
    defaultto(:present)
  end

  newparam(:listen_on, namevar: true) do
    desc 'Specifies the IP address and port for which to listen (ip:port)'
    validate do |value|
      raise('listen_on should be structured ip:port') if value !~ %r{^(.*):(.*)$}
    end
  end

  newproperty(:connect_on) do
    desc 'Specifies the IP address and port to which to connect (ip:port)'
    validate do |value|
      raise('listen_on should be structured ip:port') if value !~ %r{^(.*):(.*)$}
    end
  end

  newproperty(:protocol) do
    desc 'Protocol to establish proxy service (`v4tov4`/`v6tov6`/`v4tov6`/`v6tov4`)'
    newvalues(:v4tov4, :v6tov6, :v4tov6, :v6tov4)
    defaultto(:v4tov4)
  end
end
