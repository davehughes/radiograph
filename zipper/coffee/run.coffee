minimist = require 'minimist'
zipserver = require './server.js'

# Parse args, pass to app, run
args = minimist(process.argv)
zipserver.configure(args)
zipserver.run()
