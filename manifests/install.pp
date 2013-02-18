# = Define: pkgmngt::install
#
# This define installs a package from an rpm
#
# == Parameters
#
# [*download_url*]
# url from where to receive the rpm or a file archive (zip, tar) containing several rpms
#
# [*gpgcheck *]
# perform gpgcheck during installation, default: true
# 
define pkgmngt::install (
	$download_url,
	$gpgcheck = true,
	$onlyif = undef,
) {
	$segments = split($download_url, '[/]')
	$package_file = last_element($segments)
	$file_suffix_segments = split($download_url, '[.]')
	$file_suffix = last_element($file_suffix_segments)	
	
	case $file_suffix {
		'tar','zip','gz': {
			archmngt::extract { "pkgmngt_install_fetch_extract_${name}" :
				archive_file => "$download_url",
				target_dir => "/tmp/$package_file/",
				overwrite => true,
				before => Exec["pkgmngt_install_repo_${name}"],
			}
			$install_selection =  "/tmp/$package_file/*"
		}
		default : {
			wget::fetch {
				"pkgmngt_install_fetch_${name}" :
					source => "$download_url",
					destination => "/tmp/$package_file",
					before => Exec["pkgmngt_install_repo_${name}"],
			}	
			$install_selection = "/tmp/$package_file"
		}
	}
			
	case $::operatingsystem {
		redhat, centos, oel : {
			$pkgmngt = "/usr/bin/yum"			
			$param_gpgcheck = $gpgcheck ? {
				false => ' --nogpgcheck',
				default => ''
			}
			exec {
				"pkgmngt_install_repo_${name}" :
					command => "$pkgmngt -y$param_gpgcheck install $install_selection",
					cwd => "/tmp",
					onlyif => $onlyif,
			}
		}
		default : {
			exec {
				"pkgmngt_install_repo_${name}" :
					command => "/bin/echo \"operating system $::operatingsystem not yet supported by repomngt\"",
										
			}
			fail("operating system $::operatingsystem not yet supported by repomngt")
		}
	}
}