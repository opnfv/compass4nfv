# Kickstart for Profile: CentOS7.3_aarch64
# Distro: CentOS7.3

# System Authorization
auth --useshadow --enablemd5

#if $os_version == "rhel7"
eula --agreed
services --enabled=NetworkManager,sshd
#end if

# Use Graphic Mode
text

# Disable Firewall
firewall --disabled

# Run the Setup Agent on first-boot
firstboot --disable

# System Keyboard
keyboard us

# Language Setting
lang en_US

# Installation Loggin Level
logging --level=info

# Network Installation
url --url=$tree


$SNIPPET('kickstart_network_config')
$SNIPPET('kickstart_yum_repo_config')

# Set User Password
#if $getVar('username', 'root') != "root"
rootpw root
    #set username = $getVar('username', 'root')
    #set crypted_param = ''
    #set password_param = '--password=%s' % $username
    #if $getVar('password', '') != ""
        #set crypted_param = '--iscrypted'
        #set password_param = '--password=%s' % $password
    #end if
user --name=$username $crypted_param $password_param
#else
    #if $getVar('password', '') != ""
rootpw --iscrypted $password
    #else
rootpw root
    #end if
#end if

# Selinux Disable
selinux --disabled

# No X Window System
skipx

# System Timezone
#if $getVar('timezone', '') != ""
timezone --utc $timezone
#else
timezone --utc US/Pacific
#end if

ignoredisk --only-use=sda
bootloader --location=mbr
clearpart --drives=sda --all --initlabel
part /boot/efi --fstype=efi --size=200
part /boot --fstype=ext4 --size=512
part / --fstype=ext4 --size=10240 --grow
part swap --size=4000

# Install
install

# Reboot After Installation
reboot

%pre
$SNIPPET('kickstart_pre_log')
$SNIPPET('kickstart_start')
$SNIPPET('kickstart_pre_install_network_config')

# Enable installation monitoring
$SNIPPET('kickstart_pre_anamon')
%end

# Packages
%packages --nobase
@core
iproute
# ntp
openssh-clients
# wget
# yum-plugin-priorities
json-c
libestr
rsyslog
parted
# vim
# lsof
# strace
# if $os_version == "rhel7"
# net-tools
# end if
#if $getVar('tool', '') != ''
    #set $kickstart_software = "kickstart_software_%s" % $tool
$SNIPPET($kickstart_software)
#end if
%end

%post --log=/var/log/post_install.log
$SNIPPET('kickstart_post_log')
$SNIPPET('kickstart_post_install_kernel_options')
$SNIPPET('kickstart_post_install_network_config')

chkconfig iptables off
chkconfig ip6tables off

$SNIPPET('kickstart_yum')
$SNIPPET('kickstart_ssh')
# $SNIPPET('kickstart_ntp')
$SNIPPET('kickstart_limits.conf')
$SNIPPET('kickstart_sysctl.conf')
$SNIPPET('kickstart_rsyslog.conf')
#if $getVar('tool', '') != ''
    #set $kickstart_tool = "kickstart_%s" % $tool
$SNIPPET($kickstart_tool)
#end if
$SNIPPET('kickstart_post_anamon')
$SNIPPET('kickstart_done')
%end
