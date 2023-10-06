package com.tvd.eqx

import akka.Done
import akka.actor.{ActorSystem, CoordinatedShutdown}
import akka.http.scaladsl.Http
import akka.http.scaladsl.server.Route
import com.tvd.eqx.Constant.ActorSystem.Name
import com.tvd.eqx.Constant.Basic.PathPrefix
import com.tvd.eqx.Constant.Http._
import com.tvd.eqx.security.HttpsConnection
import com.tvd.eqx.service.ServiceRoutes
import com.typesafe.config.{Config, ConfigFactory}

import scala.concurrent.duration.DurationInt
import scala.concurrent.{ExecutionContextExecutor, Future}

object WebServer extends ServiceRoutes with Logger with HttpsConnection {

  val ProtocolHttps: String = "https"

  var binding: Future[Http.ServerBinding] = _

  override implicit def system: ActorSystem = ActorSystem(Name)

  def main(args: Array[String]): Unit = {
    logger.info("")
    logger.info("")
    logger.info("------------------------ start ----------------------")
    logger.info("")
    logger.info("")
    logger.info("""  _____         _________""")
    logger.info("""    ______ ________ ___(_)_______ ______  /____  __""")
    logger.info("""  _  __ `/__  __ \__  / __  __ \_  __  / _  / / /""")
    logger.info("""  / /_/ / _  / / /_  /  _  / / // /_/ /  / /_/ /""")
    logger.info("""  \__,_/  /_/ /_/ /_/   /_/ /_/ \__,_/   \__,_/""")
    logger.info("")
    logger.info("")
    logger.info("------------------------------------------------------")
    logger.info("|                eqx                  |")
    logger.info("------------------------------------------------------")
    logger.info("Starting the system...")

    implicit val executionContext: ExecutionContextExecutor = system.dispatcher

    lazy val routes: Route = serviceRoutes
    val conf: Config = ConfigFactory.load()

    val scheme = conf.getString(Scheme)
    val interface = conf.getString(Interface)
    val port = conf.getInt(Port)
    val isHttps = scheme.equalsIgnoreCase(ProtocolHttps)

    if(isHttps) {
      binding = Http().newServerAt(interface, port).enableHttps(https).bind(routes)
          .map(_.addToCoordinatedShutdown(hardTerminationDeadline = 10.seconds))
    } else {
      binding = Http().newServerAt(interface, port).bind(routes)
        .map(_.addToCoordinatedShutdown(hardTerminationDeadline = 10.seconds))
    }

    logger.info("The system has been started")
    logger.info(s"Server online at $scheme://localhost:$port/$PathPrefix")
    logger.info("The system is ready")
    logger.info("...")

    CoordinatedShutdown(system).addTask(
      CoordinatedShutdown.PhaseBeforeServiceUnbind, "https_shutdown") { () =>

      binding.flatMap(_.unbind()).flatMap { _ =>
        Http().shutdownAllConnectionPools()
      }.map { _ =>
        Done
      }
    }
  }
}
