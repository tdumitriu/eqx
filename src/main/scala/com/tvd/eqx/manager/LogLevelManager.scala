package com.tvd.eqx.manager

import com.tvd.eqx.Constant.Basic.Ok
import com.tvd.eqx.Logger
import com.tvd.eqx.manager.log.LogProcessor
import com.tvd.eqx.model.{LogLevel, LogLevelChange}

object LogLevelManager extends Logger {

  def setLogLevel(logLevel: String, path: String): LogLevelChange = {
    logger.debug("Processing the 'change log level' request")
    val (originalLogLevel, newLogLevel) = LogProcessor.set(logLevel, path)
    // TODO: This sleep is added here to test a long running job.. It's going to be removed
    // Thread.sleep(20000)
    LogLevelChange(Ok, path, originalLogLevel, newLogLevel)
  }

  def getLogLevel(path: String): LogLevel = {
    logger.debug("Processing the 'get log level' request for path [{}]", path)
    val logLevel = LogProcessor.get(path)
    LogLevel(path, logLevel)
  }
}
