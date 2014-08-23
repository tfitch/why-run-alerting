# why-run-alerting cookbook

Setup the testing machine
`kitchen converge`

And then connect to the box and see what's going on
`kitchen login` 

--why-run
`sudo chef-client -z -c /tmp/kitchen/client.rb -W`

"Chef Client finished, 0/1 resources would have been updated"

Edit the file
`echo " Ooowns. Ooowns." >> /tmp/why-run`
`more /tmp/why-run`

--why-run again
`sudo chef-client -z -c /tmp/kitchen/client.rb -W`

"Chef Client finished, 1/1 resources would have been updated"