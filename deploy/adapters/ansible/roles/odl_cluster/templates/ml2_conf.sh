cat <<EOT>> /etc/neutron/plugins/ml2/ml2_conf.ini
[ml2_odl]
password = admin
username = admin
url = http://{{ HA_VIP }}:8080/controller/nb/v2/neutron
EOT
