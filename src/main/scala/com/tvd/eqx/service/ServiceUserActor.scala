package com.tvd.eqx.service

import akka.actor.{Actor, Props}
import com.tvd.eqx.Logger
import com.tvd.eqx.manager.UserManager._
import com.tvd.eqx.model.User

object ServiceUserActor {
  final case object GetUsers
  final case class CreateUser(user: User)
  final case class UpdateUser(user: User)
  final case class GetUser(id: String)
  final case class DeleteUser(name: String)

  def props: Props = Props[ServiceUserActor]()
}

class ServiceUserActor extends Actor with Logger {

  import ServiceUserActor._

  override def preStart(): Unit = {
    logger.debug("Starting service User actor...")
  }

  override def preRestart(reason: Throwable, message: Option[Any]): Unit = {
    logger.error(s"Service User actor restarted because of: ${message.getOrElse("unknown error").toString}", reason)
  }

  def receive: Receive = {
    case GetUsers =>
      sender() ! getAllUsers
    case CreateUser(user) =>
      sender() ! createUser(user)
    case UpdateUser(user) =>
      sender() ! updateUser(user)
    case GetUser(name) =>
      sender() ! getUserByUsername(name)
    case DeleteUser(id) =>
      sender() ! deleteUserById(id)
  }
}
