define(["log4JavaScript", "text!data/config.txt"], (log4JavaScript, configText)->
  configLevel = JSON.parse(configText).logLevel
  consoleAppender = new log4JavaScript.BrowserConsoleAppender()
  consoleAppender.setThreshold(log4JavaScript.Level.TRACE)
  if configLevel?
    log4JavaScript.getRootLogger().setLevel(log4JavaScript.Level[configLevel])
  else
    log4JavaScript.getRootLogger().setLevel(log4JavaScript.Level.WARN)
  log4JavaScript.getRootLogger().addAppender(consoleAppender)
  LoggerFactory =
    getLogger : ()->
      log4JavaScript.getRootLogger()
  LoggerFactory

)

