cat <<EOT>> /etc/neutron/plugins/ml2/ml2_conf.ini
[ml2_odl]
password = admin
username = admin
url = http://{{ hostvars[inventory_hostname]['ansible_' + INTERNAL_INTERFACE].ipv4.address }}:8080/controller/nb/v2/neutron
EOT

