#
# Cookbook:: backend_search_cluster
# Recipe:: backend_es.rb
#
# Copyright:: 2017, The Authors, All Rights Reserved.
delivery_databag = data_bag_item('automate', 'automate')

search_bootstrap = search(:node, "chef_environment:#{node.chef_environment} AND es_bootstrap:true",
                               filter_result: { 'fqdn' => ['fqdn'] })

# if search_bootstrap has no results, you are the search_bootstrap
search_bootstrap_fqdn = search_bootstrap.empty? ? node['fqdn'] : search_bootstrap[0]['fqdn']

chef_backend node['fqdn'] do
  bootstrap_node node['search_bootstrap']
  accept_license true
  publish_address node['ipaddress']
  chef_backend_secrets delivery_databag['search_secrets'].to_s unless node['fqdn'] == node['search_bootrap']
end

ruby_block 'add search secrets to databag' do
  block do
    delivery_databag['search_secrets'] = ::File.read('/etc/chef-backend/chef-backend-secrets.json')

    @chef_rest = Chef::ServerAPI.new(
      Chef::Config[:chef_server_url],
              client_name: 'delivery',
              signing_key_filename: '/tmp/delivery.pem'
    )

    @chef_rest.put('data/automate/automate', delivery_databag)
  end
  action :nothing
  only_if { node['fqdn'] == node['search_bootstrap'] }
end
