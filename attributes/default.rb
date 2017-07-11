default['java']['jdk_version'] = '8'
default['java']['install_flavor'] = 'oracle'
default['java']['oracle']['accept_oracle_download_terms'] = true

default['logstash']['heap_size'] = '2g'
default['logstash']['workers'] = (node['cpu']['cores'].to_i * 0.75).floor  # logstash workers at a 3:4 ratio to cores
default['logstash']['bulk_size'] = '512'
default['logstash']['total_procs'] = '4'

default['elasticsearch']['es_number_of_shards'] = 3
default['elasticsearch']['es_max_content_length'] = "1gb"
