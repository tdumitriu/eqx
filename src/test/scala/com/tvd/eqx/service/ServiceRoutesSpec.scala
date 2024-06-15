package com.tvd.eqx.service

import akka.actor.ActorSystem
import akka.http.scaladsl.model.{ContentTypes, HttpEntity, StatusCodes}
import akka.http.scaladsl.server.{MissingQueryParamRejection, Route}
import akka.http.scaladsl.testkit.{RouteTestTimeout, ScalatestRouteTest}
import org.junit.runner.RunWith
import org.scalamock.scalatest.MockFactory
import org.scalatest.matchers.should.Matchers
import org.scalatest.wordspec.AnyWordSpec
import org.scalatestplus.junit.JUnitRunner

import scala.concurrent.duration.DurationInt

@RunWith(classOf[JUnitRunner])
class ServiceRoutesSpec extends AnyWordSpec with Matchers with ScalatestRouteTest with ServiceRoutes with MockFactory {

  final val MaximumRequestDuration: Int = 1

  implicit def default(implicit system: ActorSystem): RouteTestTimeout = RouteTestTimeout(new DurationInt(MaximumRequestDuration).second)

  "The main routing service" should {

    // STATUS
    "return an up status for GET status request" in {
      Get("/eqx/status") ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.OK
        contentType should === (ContentTypes.`application/json`)
        entityAs[String] should === ("""{"status":"up1"}""")
        headers shouldEqual List()
      }
    }

    "return a MethodNotAllowed error for PUT status requests where PUT is not implemented" in {
      Put("/eqx/status") ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.MethodNotAllowed
      }
    }

    // HEALTHCHECK
    "return for GET healthcheck request for database status" in {
      Get("/eqx/health/db") ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.OK
        contentType should === (ContentTypes.`application/json`)
        entityAs[String] should === ("""{"component":"postgres","status":"ok","details":"600 max connections"}""")
        headers shouldEqual List()
      }
    }

    "return for GET healthcheck request for memory status" in {
      Get("/eqx/health/mem") ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.OK
        contentType should === (ContentTypes.`application/json`)
        entityAs[String] contains """{"component":"memory","status":"ok","description":"""
        headers shouldEqual List()
      }
    }

    // LOG LEVEL
    "return successfully for POST log request with level and path query parameters" in {
      Post("/eqx/log?level=DEBUG&path=com.tvd.eqx.WebServer") ~> serviceRoutes ~> check {
        status shouldEqual StatusCodes.OK
        contentType shouldEqual ContentTypes.`text/plain(UTF-8)`
        responseAs[String] shouldEqual """{"status":"ok","path":"com.tvd.eqx.WebServer","from":"UNKNOWN","to":"DEBUG"}"""
      }
    }

    "return a missing path query parameter rejection when the parameter path is not supplied" in {
      Post("/eqx/log?level=DEBUG") ~> serviceRoutes ~> check {
        rejection shouldEqual MissingQueryParamRejection("path")
      }
    }

    "return successfully for GET log level request with path query parameter" in {
      Get("/eqx/log?path=com.tvd.eqx.WebServer") ~> serviceRoutes ~> check {
        status shouldEqual StatusCodes.OK
        contentType shouldEqual ContentTypes.`text/plain(UTF-8)`
        responseAs[String] shouldEqual """{"path":"com.tvd.eqx.WebServer","level":"DEBUG"}"""
      }
    }

    // USER
    // BEFORE: DB status = 0 rows
    //  AFTER: DB status = 0 rows
    "return empty users when DB empty for GET all the users" in {
      Get("/eqx/user") ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.OK
        contentType should === (ContentTypes.`text/plain(UTF-8)`)
        entityAs[String] should === ("""{"value":{"users":[]},"success":true,"failure":false}""")
        headers shouldEqual List()
      }
    }

    // BEFORE: DB status = 0 rows
    //  AFTER: DB status = 1 row
    "create a new user in an empty DB" in {
      Post("/eqx/user",
        HttpEntity(ContentTypes.`application/json`,
          """{
            |  "username":"gica.contra@abc.com",
            |  "password":"xyz",
            |  "firstname":"Gica",
            |  "lastname":"Contra",
            |  "street":"123 Main Street",
            |  "city":"Middletown",
            |  "state":"PA",
            |  "zip":"12345"
            |}""".stripMargin)) ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.OK
        contentType should === (ContentTypes.`text/plain(UTF-8)`)
        entityAs[String] should === (
          """[{"intValue":202,"reason":"Accepted","defaultMessage":"The request has been accepted for processing, but the processing has not been completed.","allowsEntity":true,"redirection":false,"success":true,"failure":false},{"description":"ok"}]""".stripMargin)
        headers shouldEqual List()
      }
    }

    // BEFORE: DB status = 1 row
    //  AFTER: DB status = 1 row
    "return one user for GET the user by username" in {
      Get("/eqx/user/gica.contra@abc.com") ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.OK
        contentType should === (ContentTypes.`text/plain(UTF-8)`)
        entityAs[String] should === (
          """{"value":{"user_id":0,"username":"gica.contra@abc.com","password":"xyz","firstname":"Gica","lastname":"Contra","street":"123 Main Street","city":"Middletown","state":"PA","zip":"12345"},"success":true,"failure":false}""".stripMargin)
        headers shouldEqual List()
      }
    }

    // BEFORE: DB status = 1 row
    //  AFTER: DB status = 2 rows
    "create the second user in the DB" in {
      Post("/eqx/user",
        HttpEntity(ContentTypes.`application/json`,
          """{
            |  "username":"trica.bica@xyz.org",
            |  "password":"mnp",
            |  "firstname":"Bica",
            |  "lastname":"Trica",
            |  "street":"101 Second Street",
            |  "city":"Currenttown",
            |  "state":"OR",
            |  "zip":"98765"
            |}""".stripMargin)) ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.OK
        contentType should === (ContentTypes.`text/plain(UTF-8)`)
        entityAs[String] should === (
          """[{"intValue":202,"reason":"Accepted","defaultMessage":"The request has been accepted for processing, but the processing has not been completed.","allowsEntity":true,"redirection":false,"success":true,"failure":false},{"description":"ok"}]""".stripMargin)
        headers shouldEqual List()
      }
    }

    // BEFORE: DB status = 2 rows
    //  AFTER: DB status = 2 rows
    "return two users for GET all the users" in {
      Get("/eqx/user") ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.OK
        contentType should === (ContentTypes.`text/plain(UTF-8)`)
        entityAs[String] should === ("""{"value":{"users":[{"user_id":0,"username":"gica.contra@abc.com","password":"xyz","firstname":"Gica","lastname":"Contra","street":"123 Main Street","city":"Middletown","state":"PA","zip":"12345"},{"user_id":0,"username":"trica.bica@xyz.org","password":"mnp","firstname":"Bica","lastname":"Trica","street":"101 Second Street","city":"Currenttown","state":"OR","zip":"98765"}]},"success":true,"failure":false}""")
        headers shouldEqual List()
      }
    }

    // BEFORE: DB status = 2 rows
    //  AFTER: DB status = 1 row
    "delete one user by id" in {
      Delete("/eqx/user/0") ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.OK
        contentType should === (ContentTypes.`text/plain(UTF-8)`)
        entityAs[String] should === (
          """[{"intValue":200,"reason":"OK","defaultMessage":"OK","allowsEntity":true,"redirection":false,"success":true,"failure":false},{"description":"User with id [0] deleted"}]""".stripMargin)
        headers shouldEqual List()
      }
    }

    "update an existing user" in {
      Put("/eqx/user",
        HttpEntity(ContentTypes.`application/json`,
          """
            |{
            |  "name":"Gica",
            |  "age":12,
            |  "countryOfResidence":"Uzbekistan"
            |}""".stripMargin)) ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.OK
        contentType should === (ContentTypes.`text/plain(UTF-8)`)
        entityAs[String] should === (
          """[{"intValue":202,"reason":"Accepted","defaultMessage":"The request has been accepted for processing, but the processing has not been completed.","allowsEntity":true,"redirection":false,"success":true,"failure":false},{"description":"ok"}]""".stripMargin)
        headers shouldEqual List()
      }
    }

    // OTHER
    "return a not found message for GET with only slash" in {
      Get("/") ~> Route.seal(serviceRoutes) ~> check {
        responseAs[String] shouldEqual "Not found here!"
      }
    }

    "return a not found error message for GET in the path prefix eqx with slash" in {
      Get("/eqx/") ~> Route.seal(serviceRoutes) ~> check {
        responseAs[String] shouldEqual "Not found here!"
      }
    }

    "return a not found error message for GET in the path prefix eqx without slash" in {
      Get("/eqx") ~> Route.seal(serviceRoutes) ~> check {
        responseAs[String] shouldEqual "Not found here!"
      }
    }

    "return a not found error message for GET of a non-existing path" in {
      Get("/eqx/non_existing") ~> Route.seal(serviceRoutes) ~> check {
        status shouldEqual StatusCodes.NotFound
      }
    }
  }
}
