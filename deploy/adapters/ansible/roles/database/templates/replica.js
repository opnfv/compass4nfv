config = { _id:"compass", members:[
{% for host in haproxy_hosts.values() %}
{% set pair = '%s:27017' % host %}
    {_id:{{ loop.index0 }},host:"{{ pair }}"},
{% endfor %}
]
};
rs.initiate(config);
