service Test {
  // For testing oneway messaging
  oneway void sendMessage(1:string message),

  // for testing twoway messaging
  string capitalize(1:string str)
}