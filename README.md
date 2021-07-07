![Build Status](https://ci.appveyor.com/api/projects/status/github/webalexeu/puppet-windows_port_forwarding?svg=true)
# windows_port_forwarding

#### Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Manage the windows port forwarding with Puppet (`netsh` as required).
[IPHelper service is required]

## Features
* Create/edit/delete individual port forward (`windows_port_forwarding`)

## Usage

### windows_port_forwarding
Manage individual port forward

#### Listing port foward

The type and provider is able to enumerate the port forward existing on the 
system:

```shell
C:\>puppet resource windows_port_forwarding
...
windows_port_forwarding { '*:8991':
  ensure     => 'present',
  connect_on => '*:8989',
  protocol   => 'v4tov4',
}
windows_port_forwarding { '10.137.34.85:8889':
  ensure     => 'present',
  connect_on => '*:8988',
  protocol   => 'v4tov4',
}
```

You can limit output to a single port forward by passing its name as an argument, eg:

```shell
C:\>puppet resource windows_port_forwarding '*:8991'
windows_port_forwarding { '*:8991':
  ensure     => 'present',
  connect_on => '*:8989',
  protocol   => 'v4tov4',
}
```

#### Ensuring a port forward

The basic syntax for ensuring rules is: 

```puppet
windows_port_forwarding{"${$::ipaddress}:9090":
    ensure     => present,
    protocol   => 'v4tov4',
    connect_on => '*:8988';
}
```

If a port forward with the same name but different properties already exists, it will be
updated to ensure it is defined correctly. To delete a port forward, set
`ensure => absent`.

You can use listen_on parameter if you want to define custom resource title:

```puppet
windows_port_forwarding{'port forward':
    ensure     => present,
    protocol   => 'v4tov4',
    listen_on  => '*:8990',
    connect_on => "${$::ipaddress}:8988";
}
```

#### Purging port forward

You can choose to purge unmanaged port forward from the system (be careful! - this will
remove _any_ port forward that is not manged by Puppet):

```puppet
resources { 'windows_port_forwarding':
  purge => true;
}
```


## Troubleshooting
* Try running puppet in debug mode (`--debug`)
* To reset port forward to default: `netsh interface portproxy reset`
* Print all port forward using netsh 
  `netsh interface portproxy show all`
* Help on how to 
  [create port forward](https://docs.microsoft.com/en-us/windows-server/networking/technologies/netsh/netsh-interface-portproxy)


## Limitations
* `netsh` is used. There is no PowerShell cmdlet available to manage port forward.
* Requires the `netsh interface portproxy` command


## Development

PRs accepted :)

## Testing


## Source