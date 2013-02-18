# = Define: repomngt::install::from_rpm
#
# This define installs a package from an rpm
#
# == Parameters
#
# [*download_url*]
# url from where to receive the rpm
#
# [*gpgcheck *]
# perform gpgcheck during installation, default: true
# 
define repomngt::install::from_rpm (
	$download_url,
	$gpgcheck = true,
	$onlyif = undef,
) {
	$segments = split($download_url, '[/]')
	$rpm_file = last_element($segments)
	wget::fetch {
		"repomngt_install_fetch_${name}" :
			source => "$download_url",
			destination => "/tmp/$rpm_file",
			before => Exec["repomngt_install_repo_${name}"],
	}
	case $::operatingsystem {
		redhat, centos, oel : {
			$pkgmngt = "/usr/bin/yum"			
			$param_gpgcheck = $gpgcheck ? {
				false => ' --nogpgcheck',
				default => ''
			}
			exec {
				"repomngt_install_repo_${name}" :
					command => "$pkgmngt -y$param_gpgcheck install /tmp/$rpm_file",
					cwd => "/tmp",
					onlyif => $onlyif,
			}
		}
		default : {
			exec {
				"repomngt_install_repo_${name}" :
					command => "/bin/echo \"operating system $::operatingsystem not yet supported by repomngt\"",
										
			}
			fail("operating system $::operatingsystem not yet supported by repomngt")
		}
	}
}