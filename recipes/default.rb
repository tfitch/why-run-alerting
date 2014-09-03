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

# now setup Loggly, maybe not pretty, but it'll work
remote_file '/tmp/configure-linux.sh' do
	source 'https://www.loggly.com/install/configure-linux.sh'
end

execute 'configure-loggly' do
	cwd '/tmp'
	command <<-EOH
bash configure-linux.sh -a #{node.loggly_appname} -u #{node.loggly_username} -t #{node.loggly_access_key}

mkdir -v /var/spool/rsyslog
if [ "$(lsb_release -ds | grep Ubuntu)" != "" ]; then
chown -R syslog:adm /var/spool/rsyslog
fi
	EOH
	not_if { ::File.directory?('/var/spool/rsyslog') }
end

# define the service so we can restart it with the following template
service 'rsyslog'

template '/etc/rsyslog.d/21-filemonitoring-loggly.conf' do
	source '21-filemonitoring-loggly.conf.erb'
	variables({
		:access_key => node.loggly_access_key
	})
	notifies :restart, "service[rsyslog]", :immediately
end


# now our Cron jobs to create drift and watch for it in a FizzBuzz kinda way
# insert drift in the file we created above
cron 'drift' do
  minute  '*/5'
  hour    '*'
  user    'root'
  command 'echo " Ooowns. Ooowns." >> /tmp/why-run'
end

# Chef client in --why-run mode
cron 'chef-client-why-run' do
  minute  '*/1'
  hour    '*'
  user    'root'
  command 'chef-client -z --chef-zero-port 8901 --force-formatter -W -c /tmp/kitchen/client.rb >> /tmp/why-run.log 2>&1'
end

# and Chef client to reset the file so the alert isn't always going off, but close to always
cron 'chef-client' do
  minute  '*/3'
  hour    '*'
  user    'root'
  command 'chef-client -z --chef-zero-port 8902 --force-formatter -c /tmp/kitchen/client.rb >> /tmp/why-run.log 2>&1'
end
