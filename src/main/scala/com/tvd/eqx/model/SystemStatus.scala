package com.tvd.eqx.model

import com.fasterxml.jackson.annotation.{JsonCreator, JsonProperty}

trait Details

@JsonCreator
case class SystemStatus(@JsonProperty("component") system: String,
                        @JsonProperty("status") status: String,
                        @JsonProperty("details") details: Any)

@JsonCreator
case class Memory(@JsonProperty("total") total: Long,
                  @JsonProperty("used") used: Long,
                  @JsonProperty("free") free: Long,
                  @JsonProperty("max") max: Long)
