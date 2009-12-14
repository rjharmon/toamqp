
# Illustrates how to access an asynchronous oneway service
announcer = TOAMQP::Client.new('test', Test)
announcer.announce('chunky bacon')