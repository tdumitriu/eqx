package com.tvd.eqx.dal

import slick.dbio.Effect
import slick.jdbc.JdbcProfile
import slick.sql.FixedSqlAction

/** The Data Access Layer contains all components and a profile */
class DAL(val profile: JdbcProfile) extends UserComponent with MessageComponent with ProfileComponent {
  import profile.api._

  def create: FixedSqlAction[Unit, NoStream, Effect.Schema] =
    (
      users.schema ++
      messages.schema
    ).create
}
