#
# Cookbook Name:: why-run-alerting
# Recipe:: default
#
# Copyright (C) 2014 
#
# 
#

file '/tmp/why-run' do
	content 'Who own the Chiefs?'
	owner 'vagrant'
	group 'vagrant'
end

log_file = '/tmp/why-run.log'
client_bin = 'chef-client -z --force-formatter -W -c /tmp/kitchen/client.rb'
cmd = ''
cmd << "#{client_bin} > #{log_file} 2>&1"

# now setup Chef client to run in --why-run mode via a cron job
cron 'chef-client' do
  minute  '*/2'
  hour    '*'
  user    'root'
  command cmd
end

