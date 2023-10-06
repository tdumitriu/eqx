package com.tvd.eqx.manager.status

import com.tvd.eqx.Constant.Basic.{Ok, Low}
import com.tvd.eqx.Logger
import com.tvd.eqx.model.SystemStatus

object LocalSystemStatus extends Logger {

  def getMemoryStatus: SystemStatus = {
    logger.debug("Requesting the status of the memory")

    val component = "memory"

    val Mb = 1024 * 1024
    val MinimumFreeMemPercentage = 10

    val runtime = Runtime.getRuntime

    val total = runtime.totalMemory / Mb
    val free = runtime.freeMemory / Mb
    val used = (runtime.totalMemory - runtime.freeMemory) / Mb
    val max = runtime.maxMemory / Mb
    val freeMemPercentage = (free * 100) / total

    val description = "Used:[" + used + "]," +
                      "Free:[" + free + "]," +
                      "Total:[" + total + "]," +
                      "Max:[" + max + "]"

    val status = if(freeMemPercentage > MinimumFreeMemPercentage) Ok else Low

    SystemStatus(component, status, description)
  }
}
