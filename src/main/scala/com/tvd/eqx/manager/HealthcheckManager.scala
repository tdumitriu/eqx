package com.tvd.eqx.manager

import akka.http.scaladsl.model.{ContentTypes, HttpEntity}
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.scala.{ClassTagExtensions, DefaultScalaModule}
import com.tvd.eqx.Constant.Basic.{NA, Unknown}
import com.tvd.eqx.Constant.RoutePath.{Database, Memory}
import com.tvd.eqx.Logger
import com.tvd.eqx.manager.status.{DatabaseStatus, LocalSystemStatus}
import com.tvd.eqx.model.SystemStatus

object HealthcheckManager extends Logger {

  val mapper = new ObjectMapper() with ClassTagExtensions
  mapper.registerModule(DefaultScalaModule)

  def getSystemStatus(component: String): SystemStatus = {
    component match {
      case Database => DatabaseStatus().getStatus
      case Memory => LocalSystemStatus.getMemoryStatus
      case _ => SystemStatus(Unknown, Unknown, NA)
    }
  }

  def response(systemStatus: SystemStatus): HttpEntity.Strict = {
    HttpEntity(ContentTypes.`application/json`, mapper.writeValueAsString(systemStatus))
  }
}
