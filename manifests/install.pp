define repomngt::install::from_rpm (
	$download_url,
	$gpgcheck = true
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