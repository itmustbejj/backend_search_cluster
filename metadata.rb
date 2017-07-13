name 'backend_search_cluster'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures backend_search_cluster'
long_description 'Installs/Configures backend_search_cluster'
version '0.4.8'
chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/backend_search_cluster/issues'

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/backend_search_cluster'
#
depends 'chef-ingredient'
depends 'elasticsearch', '2.5.1'
depends 'java'
depends 'sysctl'
