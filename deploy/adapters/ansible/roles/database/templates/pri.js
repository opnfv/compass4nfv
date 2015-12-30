config = rs.conf()
{% for host in haproxy_hosts.values() %}
config.members[{{ loop.index0 }}].priority = {{ haproxy_hosts|length - loop.index0 }}
{% endfor %}
rs.reconfig(config)
sleep(10)
