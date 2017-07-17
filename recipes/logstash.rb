#
# Cookbook:: backend_search_cluster
# Recipe:: logstash
#
# Copyright:: 2017, The Authors, All Rights Reserved.

ruby_block 'configure logstash settings in delivery.rb' do
  block do
    delivery_rb = Chef::Util::FileEdit.new('/etc/delivery/delivery.rb')
    unless delivery_rb.search_file_replace_line(
      /delivery['logstash']['config']['pipeline']['batch']['size']/,
      "delivery['logstash']['config']['pipeline']['batch']['size'] = #{node['logstash']['bulk_size']}"
    )
      delivery_rb.insert_line_if_no_match(
        /delivery['logstash']['config']['pipeline']['batch']['size']/,
        "delivery['logstash']['config']['pipeline']['batch']['size'] = #{node['logstash']['bulk_size']}"
      )
    end

    unless delivery_rb.search_file_replace_line(
      /delivery['logstash']['heap_size']/,
      "delivery['logstash']['heap_size'] = #{node['logstash']['heap_size']}"
    )
      delivery_rb.insert_line_if_no_match(
        /delivery['logstash']['heap_size']/,
        "delivery['logstash']['heap_size'] = #{node['logstash']['heap_size']}"
      )
    end

    unless delivery_rb.search_file_replace_line(
      /delivery['logstash']['pipeline']['workers']/,
        "delivery['logstash']['pipeline']['workers'] = #{node['logstash']['workers']}"
    )
      delivery_rb.insert_line_if_no_match(
        /delivery['logstash']['pipeline']['workers']/,
        "delivery['logstash']['pipeline']['workers'] = #{node['logstash']['workers']}"
      )
    end
    delivery_rb.write_file

    system('sudo automate-ctl reconfigure') if delivery_rb.file_edited?
  end
end

ruby_block 'reap extra logstash workers' do
  block do
    logstash_dirs = Dir['/opt/delivery/sv/logstash*']
    if node['logstash']['total_procs'] < logstash_dirs.length
      (node['logstash']['total_procs'] + 1..logstash_dirs.length).each do |i|
        system("sudo automate-ctl stop logstash#{i}")
        FileUtils.rm_rf("/opt/delivery/sv/logstash#{i}")
        FileUtils.rm_rf("/opt/delivery/embedded/etc/logstash/conf.d#{i}")
      end
    end
  end
end

(2..node['logstash']['total_procs'].to_i).each do |i|
  unless Dir.exist?("/opt/delivery/sv/logstash#{i}")
    execute "copy logstash sv dir for logstash#{i}" do
      command "cp -r /opt/delivery/sv/logstash/ /opt/delivery/sv/logstash#{i}"
    end

    execute "copy logstash conf dir for logstash#{i}" do
      command "cp -r /opt/delivery/embedded/etc/logstash/conf.d /opt/delivery/embedded/etc/logstash/conf.d#{i}"
    end

    file "/opt/delivery/embedded/etc/logstash/conf.d#{i}/10-websocket-output.conf" do
      action :delete
    end
  end

  link "/opt/delivery/service/logstash#{i}" do
    to "/opt/delivery/sv/logstash#{i}"
  end

  link "/opt/delivery/init/logstash#{i}" do
    to '/opt/delivery/embedded/bin/sv'
  end

  directory "/var/log/delviery/logstash#{i}"
  ruby_block "create directories for logstash#{i}" do
    block do
      ls_run_file = Chef::Util::FileEdit.new("/opt/delivery/sv/logstash#{i}/run")
      ls_run_file.search_file_replace(/conf\.d/, "conf.d#{i}")
      ls_run_file.search_file_replace(/-w [0-9]+/, "-w #{node['logstash']['workers']}")
      ls_run_file.search_file_replace(/-b [0-9]+/, "-w #{node['logstash']['bulk_size']}")
      ls_run_file.search_file_replace(/LS_HEAP_SIZE=[0-9]*m/, "LS_HEAP_SIZE=#{node['logstash']['heap_size']}")
      ls_run_file.write_file
      ls_log_run_file = Chef::Util::FileEdit.new("/opt/delivery/sv/logstash#{i}/log/run")
      ls_log_run_file.search_file_replace(/logstash/, "logstash#{i}")
      ls_log_run_file.write_file
      system("sudo automate-ctl restart logstash#{i}") if ls_run_file.file_edited? || ls_log_run_file.file_edited?
    end
  end
end
