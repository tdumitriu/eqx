package com.tvd.eqx.dal

import com.tvd.eqx.model.{Message, User}
import slick.lifted.{ForeignKeyQuery, ProvenShape, TableQuery}
import com.tvd.eqx.dal.*
//import akka.http.impl.util.JavaMapping.Implicits.convertToScala
//import akka.http.javadsl.server.RoutingJavaMapping.Implicits.convertToScala

trait MessageComponent { this: ProfileComponent & UserComponent =>
  import profile.api._

  class MessageTable(tag: Tag) extends Table[Message](tag, "MESSAGE") {
    def messageId: Rep[Long] = column[Long]("MESSAGE_ID", O.PrimaryKey, O.AutoInc)
    def senderId: Rep[Long] = column[Long]("SENDER_ID")
    def content: Rep[String] = column[String]("CONTENT")
//    def sender: ForeignKeyQuery[UserTable, User] = foreignKey("sender_fk", senderId, TableQuery[UserTable])(_.userId)

    def * : ProvenShape[Message] = (messageId, senderId, content).mapTo[Message]
  }

  val messages = TableQuery[MessageTable]

  private val messagesAutoInc = messages returning messages.map(_.messageId)

//  def insert(user: User): DBIO[User] = for {
//    //#insert
//    pic <-
//      if(user.userId.isEmpty) insert(user.)
//      else DBIO.successful(user.picture)
//    //#insert
//    id <- usersAutoInc += (user.name, pic.id.get)
//  } yield user.copy(picture = pic, id = id)

  //  def insert(message: Message): DBIO[Message] =
//    (picturesAutoInc += message).map(id => message.copy(messageId = id))
}