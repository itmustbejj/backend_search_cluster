#
# Cookbook:: backend_search_cluster
# Recipe:: logstash
#
# Copyright:: 2017, The Authors, All Rights Reserved.

execute 'create multiple logstash processes' do
  command <<-EOH
    for ii in $(seq 2 #{node['logstash_extra_procs']}); do
      cp -r /opt/delivery/sv/logstash/ /opt/delivery/sv/logstash$ii
        cp -r /opt/delivery/embedded/etc/logstash/conf.d /opt/delivery/embedded/etc/logstash/conf.d$ii
        rm /opt/delivery/embedded/etc/logstash/conf.d$ii/10-websocket-output.conf
        sed -i s/conf\.d/conf\.d$ii/ /opt/delivery/sv/logstash$ii/run
        ln -s /opt/delivery/sv/logstash$ii /opt/delivery/service/logstash$ii
        ln -s /opt/delivery/embedded/bin/sv /opt/delivery/init/logstash$ii
        mkdir -p /var/log/delivery/logstash$ii
        sed -i s/logstash/logstash$ii/ /opt/delivery/sv/logstash$ii/log/run
        delivery-ctl start logstash$ii
    done
  EOH
end
