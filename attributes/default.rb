default['java']['jdk_version'] = '8'
default['java']['install_flavor'] = 'oracle'
default['java']['oracle']['accept_oracle_download_terms'] = true

#default['logstash']['heap_size'] = '2g'
#default['logstash']['proc_workers'] = (node['cpu']['cores'].to_i *.75).floor  # logstash workers at a 3:4 ratio to cores
#default['logstash']['batch_size'] = 512
#default['logstash']['num_procs'] = 4
