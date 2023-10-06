package com.tvd.eqx.manager

import akka.http.scaladsl.model.{ContentTypes, HttpEntity}
import com.tvd.eqx.Logger

object PingManager extends Logger {

  def response(): HttpEntity.Strict = {
    logger.debug("Processing the 'ping' request")
    HttpEntity(ContentTypes.`text/plain(UTF-8)`, "pong")
  }
}
