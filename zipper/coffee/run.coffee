minimist = require 'minimist'
zipserver = require './server'

# Parse args, pass to app, run
args = minimist(process.argv)
zipserver.configure(args)
zipserver.run()
