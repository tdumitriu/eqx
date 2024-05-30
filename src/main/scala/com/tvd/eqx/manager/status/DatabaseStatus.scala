package com.tvd.eqx.manager.status

import com.tvd.eqx.Constant.Basic.Ok
import com.tvd.eqx.Logger
import com.tvd.eqx.model.SystemStatus

class DatabaseStatus extends Logger {

  def getStatus: SystemStatus = {
    logger.debug("Requesting the status of the database")

    val component = "postgres"
    val status = Ok
    val details = "600 max connections"

    SystemStatus(component, status, details)
  }
}

object DatabaseStatus {

  def apply() = new DatabaseStatus()
}
