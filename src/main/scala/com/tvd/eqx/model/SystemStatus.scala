package com.tvd.eqx.model

import com.fasterxml.jackson.annotation.{JsonCreator, JsonProperty}

@JsonCreator
case class SystemStatus(@JsonProperty("component") system: String,
                        @JsonProperty("status") status: String,
                        @JsonProperty("description") description: String)
