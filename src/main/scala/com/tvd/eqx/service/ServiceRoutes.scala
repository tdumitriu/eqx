package com.tvd.eqx.service

import akka.actor.{ActorRef, ActorSystem, Props}
import akka.http.scaladsl.model.StatusCodes
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server.Route
import akka.http.scaladsl.server.directives.MethodDirectives.{delete, get, post}
import akka.http.scaladsl.server.directives.PathDirectives.path
import akka.http.scaladsl.server.directives.RouteDirectives.complete
import akka.pattern.ask
import akka.util.Timeout
import com.fasterxml.jackson.module.scala.DefaultScalaModule
import com.tvd.eqx.Constant.Basic.PathPrefix
import com.tvd.eqx.Constant.{Http, RoutePath}
import com.tvd.eqx.Logger
import com.tvd.eqx.manager.UserManager.ActionPerformed
import com.tvd.eqx.manager.{HealthcheckManager, JsonService, StatusManager}
import com.tvd.eqx.model.{SystemStatus, User, Users}
import com.tvd.eqx.service.ServiceHealthcheckActor.GetSystemStatus
import com.tvd.eqx.service.ServiceLogLevelActor.{GetLogLevel, SetLogLevel}
import com.tvd.eqx.service.ServiceUserActor._
import com.typesafe.config.{Config, ConfigFactory}

import scala.concurrent.duration._
import scala.concurrent.{Await, Future}

trait ServiceRoutes extends Logger {

  implicit def system: ActorSystem

  val userActor: ActorRef = system.actorOf(Props[ServiceUserActor](), name = "ServiceUserActor")
  val logLevelActor: ActorRef = system.actorOf(Props[ServiceLogLevelActor](), name = "ServiceLogLevelActor")
  val statusActor: ActorRef = system.actorOf(Props[ServiceHealthcheckActor](), name = "ServiceStatusActor")

  val conf: Config = ConfigFactory.load()

  val httpTimeout: Int = conf.getInt(Http.Timeout)
  implicit lazy val timeout: Timeout = Timeout(Duration(httpTimeout, SECONDS))

  def module: DefaultScalaModule.type = DefaultScalaModule

  lazy val serviceRoutes: Route =
    pathPrefix(PathPrefix) {
      concat(
        path(RoutePath.Status) {
          get {
            complete {
              StatusManager.response()
            }
          }
        },
//        path(RoutePath.Health / Segment) {
//          get {
//            withRequestTimeout(100.seconds) {
//              (component: String) =>
//                val systemStatus: Future[SystemStatus] = (statusActor ? GetSystemStatus(component)).mapTo[SystemStatus]
//                onSuccess(systemStatus) { 
//                  status => complete(HealthcheckManager.response(status)) 
//                }
//            }
//          }
//        },
        path(RoutePath.Log) {
          concat(
            get {
              parameters("path".as[String]) {
                (path: String) =>
                  val logLevelResponse: Future[String] = (logLevelActor ? GetLogLevel(path)).mapTo[String]
                  onSuccess(logLevelResponse) { 
                    response => complete(response) 
                  }
              }
            },
            post {
              parameters("level".as[String], "path".as[String]) {
                (logLevel: String, path: String) =>
                  val changedLogLevelResponse: Future[String] = (logLevelActor ? SetLogLevel(logLevel, path)).mapTo[String]
                  onSuccess(changedLogLevelResponse) { 
                    response => complete(response) 
                  }
              }
            }
          )
        },
        // client http
        // gzip
        pathPrefix(RoutePath.User) {
          pathEnd {
            concat(
              // GET all users
              get {
                val users: Future[Users] = (userActor ? GetUsers).mapTo[Users]
                Await.result(users, timeout.duration)
                complete(mapper.writeValueAsString(users))
              },
              // POST (create) user
              post {
                entity(JsonService.jsonUnmarshaller[User]) { user =>
                  val userCreated: Future[ActionPerformed] = (userActor ? CreateUser(user)).mapTo[ActionPerformed]
                  onSuccess(userCreated) { performed =>
                    complete(mapper.writeValueAsString((StatusCodes.Accepted, performed)))
                  }
                }
              },
              // PUT (update) user
              put {
                entity(JsonService.jsonUnmarshaller[User]) { user =>
                  val userUpdated: Future[ActionPerformed] = (userActor ? UpdateUser(user)).mapTo[ActionPerformed]
                  onSuccess(userUpdated) { performed =>
                    complete(mapper.writeValueAsString((StatusCodes.Accepted, performed)))
                  }
                }
              }
            )
          }
        },
        path(RoutePath.User / Segment) { id =>
          concat(
            // GET (read) user by id
            get {
              val maybeUser: Future[Option[User]] = (userActor ? GetUser(id)).mapTo[Option[User]]
              Await.result(maybeUser, timeout.duration)
              rejectEmptyResponse {
                complete(mapper.writeValueAsString(maybeUser))
              }
            },
            // DELETE (remove) user by id
            delete {
              val userDeleted: Future[ActionPerformed] = (userActor ? DeleteUser(id)).mapTo[ActionPerformed]
              onSuccess(userDeleted) { performed =>
                complete(mapper.writeValueAsString((StatusCodes.OK, performed)))
              }
            }
          )
        },
        path(RoutePath.Webpages) {
          concat(
            // GET (read) user by id
            get {
              getFromResource("resources/web/index.html")
            }
          )
        }
      )
    }

  private def xxx = {
    entity(JsonService.jsonUnmarshaller[User]) { user =>
      val userUpdated: Future[ActionPerformed] = (userActor ? UpdateUser(user)).mapTo[ActionPerformed]
      onSuccess(userUpdated) { performed =>
        complete(mapper.writeValueAsString((StatusCodes.Accepted, performed)))
      }
    }
  }
}
