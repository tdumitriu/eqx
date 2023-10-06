package com.tvd.eqx.model

import com.fasterxml.jackson.annotation.{JsonCreator, JsonProperty}

@JsonCreator
final case class Message(@JsonProperty("message_id") messageId: Long,
                         @JsonProperty("senderId") senderId: Long,
                         @JsonProperty("content") content: String)

@JsonCreator
final case class Messages(@JsonProperty("messages") messages: Seq[Message])
