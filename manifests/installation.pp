define dotnet::installation(
  $version     = $title,
  $source      = undef,
  $destination = 'C:\Support'
) {

  if $source {
    $location = $source

  } else {
    $exe_name = "dotnetfx${version}_full_x86_x64.exe"
    $location = "puppet:///modules/${module_name}/${exe_name}"
  }

  $on_disk = "${destination}\\dotnetfx.exe"

  if $version == '45' {
    $prettier_ver = '4.5'
  } else {
    $prettier_ver = '4.0'
  }

  file { $on_disk:
    ensure => file,
    source => $location,
    mode   => '750',
  } ->
  package { "Microsoft .NET Framework ${prettier_ver}":
    ensure => present,
    source => $on_disk,
    #install_options => [ '/q', '/norestart' ],
    provider => 'msi',
    #puppet 2.7 requires a hash for install_options 
    #install_options => { ' ' => '/quiet /norestart' }
  }
}
