
################
# Filtering messages by headers, round robin load balancing, messages will wait

service = Service.new('repositories')

git_service1 = service.endpoint(:type => 'git', :version => '1.0.0')
git_service2 = service.endpoint(:type => 'git', :version => '1.0.0')

svn_service = service.endpoint(:type => 'svn', :version => '1.0.0')

git_service1.queue_name # => repositories_type_git_version_1_0_0
git_service2.queue_name # => repositories_type_git_version_1_0_0

svn_service.queue_name # => repositories_type_svn_version_1_0_0

client_transport = service.transport(:type => 'git', :version => '1.0.0')
server_transport = git_service.transport

################
# Broadcast (messages will not wait for receivers)

service = Service.new('broadcast')

listener1 = service.private_endpoint()
listener2 = service.private_endpoint()

listener1.queue_name # => broadcast-UUID1
listener2.queue_name # => broadcast-UUID2

client_transport = service.transport
server_transport = listener1.transport

################
# Round robin, no filtering, messages will wait for receivers

service = Service.new('round_robin')

worker1 = service.endpoint()
worker2 = service.endpoint()

worker1.queue_name # => broadcast
worker2.queue_name # => broadcast

################
# Two-way messaging

service = Service.new('twoway', :twoway => true)

server_ep = service.endpoint()

server_ep.queue_name # => 'twoway'

client_transport = service.transport  # will connect client to twoway_client_UUID as well
server_transport = server_ep.transport

