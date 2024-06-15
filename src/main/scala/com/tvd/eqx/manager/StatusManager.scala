package com.tvd.eqx.manager

import akka.http.scaladsl.model.{ContentTypes, HttpEntity}
import com.tvd.eqx.Logger

object StatusManager extends Logger {

  def response(): HttpEntity.Strict = {
    logger.debug("Processing the 'status' request")
    HttpEntity(ContentTypes.`application/json`, """{"status":"up1"}""")
  }
}
