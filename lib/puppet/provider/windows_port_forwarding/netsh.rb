Puppet::Type.type(:windows_port_forwarding).provide(:windows_port_forwarding, :parent => Puppet::Provider) do
  confine :osfamily => :windows
  mk_resource_methods
  desc "Windows Port Forwarding"

  # Actually, Windows as different settings under 32-bit or 64-bit
  def self.netsh_command
    if File.exists?("#{ENV['SYSTEMROOT']}\\System32\\netsh.exe")
      "#{ENV['SYSTEMROOT']}\\System32\\netsh.exe"
    else
      'netsh.exe'
    end
  end

  commands :netsh => netsh_command

  def self.instances
    proxy = {
      'ensure' => :absent
    }
    cmd = [ 'cmd.exe', '/c', command(:netsh), 'interface', 'portproxy', 'show' , 'all']
  
    raw = Puppet::Util::Execution.execute(cmd)
    status = raw.exitstatus
    
    instances = []
    protocol = ''

    raw.each_line() do |line|
      next if line =~ /^\s*(#|$)/
      if line =~ /^Listen on ipv4:(.*)Connect to ipv4:$/
        protocol = 'v4tov4'
        next
      end
      if line =~ /^Listen on ipv4:(.*)Connect to ipv6:$/
        protocol = 'v4tov6'
        next
      end
      if line =~ /^Listen on ipv6:(.*)Connect to ipv4:$/
        protocol = 'v6tov4'
        next
      end
      if line =~ /^Listen on ipv6:(.*)Connect to ipv6:$/
        protocol = 'v6tov6'
        next
      end
      if line =~ /^Address(.*)$/
        next
      end
      if line =~ /^---------------(.*)$/
        next
      end
      if line =~ /^(.*)?$/
        portproxy_rule = $1.split(' ')
        portproxy = {
          :name            => "#{portproxy_rule[0]}:#{portproxy_rule[1]}",
          :ensure          => :present,
          :protocol        => protocol,
          :listen_on       => "#{portproxy_rule[0]}:#{portproxy_rule[1]}",
          :connect_on      => "#{portproxy_rule[2]}:#{portproxy_rule[3]}"
        }
        instances << new(portproxy)
        next
      end
      Puppet.warning('Unable to parse line %s' % line)
    end
    instances
  end


  def self.prefetch(resources)
    instances.each do |instance|
      if resource = resources[instance.name]
        resource.provider = instance
      end
    end
  end


  def exists?
    @property_hash[:ensure] == :present
  end


  def create
    cmd = [ 'cmd.exe', '/c', command(:netsh), 'interface', 'portproxy', 'add', "#{@resource[:protocol]}", "listenaddress=#{@resource[:listen_on].split(':')[0]}", "listenport=#{@resource[:listen_on].split(':')[1]}", "connectaddress=#{@resource[:connect_on].split(':')[0]}", "connectport=#{@resource[:connect_on].split(':')[1]}" ]
    Puppet::Util::Execution.execute(cmd)
  end


  def destroy
    cmd = [ 'cmd.exe', '/c', command(:netsh), 'interface', 'portproxy', 'delete', "#{@resource[:protocol]}", "listenaddress=#{@resource[:listen_on].split(':')[0]}", "listenport=#{@resource[:listen_on].split(':')[1]}" ]
    Puppet::Util::Execution.execute(cmd)
  end


  def flush
    if @property_hash[:ensure] == @resource[:ensure]
      cmd = [ 'cmd.exe', '/c', command(:netsh), 'interface', 'portproxy', 'set', "#{@resource[:protocol]}", "listenaddress=#{@resource[:listen_on].split(':')[0]}", "listenport=#{@resource[:listen_on].split(':')[1]}", "connectaddress=#{@resource[:connect_on].split(':')[0]}", "connectport=#{@resource[:connect_on].split(':')[1]}" ]
      Puppet::Util::Execution.execute(cmd)
    end
  end

end