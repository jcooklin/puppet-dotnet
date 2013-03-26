define dotnet::installation(
  $version     = $title,
  $source      = undef,
  $destination = 'C:\\packages'
) {

  if $source {
    $location = $source

  } else {
    $exe_name = "dotnetfx${version}_full_x86_x64.exe"
    $location = "puppet:///modules/${module_name}/${exe_name}"
  }

  $on_disk = "${destination}\\dotnetfx.exe"

    exec {'deleteBlockingKey' :
    #command   => 'cmd.exe /c C:\removeUpdate.ps1',
    command => "C:\\Support\Tools\Start64.exe \
       \"c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe \
       -ExecutionPolicy Bypass \
       -File C:\\removeUpdate.ps1\"",
    path      => $::path,
    require   => File['c:\\removeUpdate.ps1'],
    logoutput => true,
    #creates  => 'c:\\dotnet45.log',
  }

  file { $destination :
     ensure => directory,
     mode   => 777,
  }

  file { $on_disk:
    ensure => file,
    source => $location,
    mode   => '750',
  }

  if $version == '45' {
    $prettier_ver = '4.5'
  } else {
    $prettier_ver = '4.0'
  }

  # An exec is required for a non-msi install. The Package type will only work
  # in  Puppet 3.0 or > because provider 'msi' was decrememted for the new
  # 'windows' provider is puppet 3.0, which can handle msi and non-msi installs.
  
  file { 'c:\\removeUpdate.ps1' :
     ensure  => present,
     source  => "puppet:///modules/dotnet/removeUpdate.ps1"
  }

  exec { 'installDotNet' :
    #     command => "c:\\support\\Tools\\start64.exe \
    #             'cmd.exe /c \"$on_disk /q /norestart\"'", 
     command   => "cmd.exe /c $on_disk /q /norestart",
     path      => $::path,
     logoutput => true,
     #unless   => 'REG Query \"HKLM\\Software\\microsoft\\NET Framework Setup\\NDP\\v4\\Full\\" /v Release', 
     creates   => 'c:\\dotnet45.log',
     require  => [ Exec['deleteBlockingKey'] ],
  } ->
  file { 'c:\\dotnet45.log' :
     ensure      => present,
  } 

/*  package { "Microsoft .NET Framework ${prettier_ver}":
    ensure           => installed,
    source           => $on_disk,
    install_options => [ '/q', '/norestart' ],
  } */
}
