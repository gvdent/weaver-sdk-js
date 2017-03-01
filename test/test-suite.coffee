# Libs
Promise      = require('bluebird')
config       = require('config')
cuid         = require('cuid')
chai         = require('chai')
sinon        = require('sinon')
Weaver       = require('../src/Weaver')

# Use chai as promised
chai.use(require('chai-as-promised'));

# You need to call chai.should() before being able to wrap everything with should
chai.should();

# Expose global fields (within all tests)
global.Promise = Promise
global.Weaver  = Weaver
global.cuid    = cuid
global.expect  = chai.expect
global.assert  = chai.assert
global.should  = chai.should
global.sinon   = sinon

# Local vars
project = null
WEAVER_ENDPOINT = config.get("weaver.endpoint")

wipe = (systemWipe) ->
  coreManager = Weaver.getCoreManager()
  Promise.all([
    coreManager.wipe("$SYSTEM") if systemWipe
    coreManager.wipe(project.id()) if project?
  ])

# Runs before all tests
before (done) ->
  Weaver.connect(WEAVER_ENDPOINT)
  .then(->
    wipe(true)
  ).then(->
    # To not wait long for project creation, set the retry timeout to low
    Weaver.Project.READY_RETRY_TIMEOUT = 1  # ms

    # Create project and use it
    project = new Weaver.Project()
    project.create()
  ).then(->
    Weaver.useProject(project)
    # Authenticate
    done()
  )
  .catch((e)->
    console.log(e)
  )
  return

# Runs after all tests
after (done) ->
#  project.destroy().then(->
##    wipe(true)
#  ).then(->
  done()
#  )
#  .catch((e)->
#    console.log(e)
#  )
  return

# Runs before each test
beforeEach (done)->
  done()
  return

# Runs after each test
afterEach ->
#  wipe()
