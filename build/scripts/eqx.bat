@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%"=="" @echo off
@rem ##########################################################################
@rem
@rem  eqx startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%"=="" set DIRNAME=.
@rem This is normally unused
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and EQX_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if %ERRORLEVEL% equ 0 goto execute

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\eqx-0.1.jar;%APP_HOME%\lib\akka-stream_2.13-2.8.2.jar;%APP_HOME%\lib\akka-serialization-jackson_2.13-2.8.2.jar;%APP_HOME%\lib\akka-slf4j_2.13-2.8.2.jar;%APP_HOME%\lib\akka-actor_2.13-2.8.2.jar;%APP_HOME%\lib\akka-http_2.13-10.5.2.jar;%APP_HOME%\lib\slick_2.13-3.4.1.jar;%APP_HOME%\lib\scala-java8-compat_2.13-1.0.0.jar;%APP_HOME%\lib\ssl-config-core_2.13-0.6.1.jar;%APP_HOME%\lib\akka-http-core_2.13-10.5.2.jar;%APP_HOME%\lib\jackson-datatype-jdk8-2.13.5.jar;%APP_HOME%\lib\jackson-datatype-jsr310-2.13.5.jar;%APP_HOME%\lib\jackson-module-parameter-names-2.13.5.jar;%APP_HOME%\lib\jackson-dataformat-cbor-2.13.5.jar;%APP_HOME%\lib\jackson-databind-2.13.5.jar;%APP_HOME%\lib\jackson-core-2.13.5.jar;%APP_HOME%\lib\jackson-annotations-2.13.5.jar;%APP_HOME%\lib\jackson-module-scala_2.13-2.13.5.jar;%APP_HOME%\lib\scala-collection-compat_2.13-2.8.1.jar;%APP_HOME%\lib\akka-parsing_2.13-10.5.2.jar;%APP_HOME%\lib\scala-library-2.13.11.jar;%APP_HOME%\lib\config-1.4.2.jar;%APP_HOME%\lib\logback-classic-1.4.8.jar;%APP_HOME%\lib\selenium-java-4.10.0.jar;%APP_HOME%\lib\akka-protobuf-v3_2.13-2.8.2.jar;%APP_HOME%\lib\selenium-chrome-driver-4.10.0.jar;%APP_HOME%\lib\selenium-devtools-v112-4.10.0.jar;%APP_HOME%\lib\selenium-devtools-v113-4.10.0.jar;%APP_HOME%\lib\selenium-devtools-v114-4.10.0.jar;%APP_HOME%\lib\selenium-firefox-driver-4.10.0.jar;%APP_HOME%\lib\selenium-devtools-v85-4.10.0.jar;%APP_HOME%\lib\selenium-edge-driver-4.10.0.jar;%APP_HOME%\lib\selenium-ie-driver-4.10.0.jar;%APP_HOME%\lib\selenium-safari-driver-4.10.0.jar;%APP_HOME%\lib\selenium-support-4.10.0.jar;%APP_HOME%\lib\selenium-chromium-driver-4.10.0.jar;%APP_HOME%\lib\selenium-remote-driver-4.10.0.jar;%APP_HOME%\lib\async-http-client-2.12.3.jar;%APP_HOME%\lib\netty-reactive-streams-2.0.4.jar;%APP_HOME%\lib\reactive-streams-1.0.4.jar;%APP_HOME%\lib\lz4-java-1.8.0.jar;%APP_HOME%\lib\async-http-client-netty-utils-2.12.3.jar;%APP_HOME%\lib\slf4j-api-2.0.7.jar;%APP_HOME%\lib\logback-core-1.4.8.jar;%APP_HOME%\lib\selenium-manager-4.10.0.jar;%APP_HOME%\lib\selenium-http-4.10.0.jar;%APP_HOME%\lib\selenium-json-4.10.0.jar;%APP_HOME%\lib\selenium-api-4.10.0.jar;%APP_HOME%\lib\paranamer-2.8.jar;%APP_HOME%\lib\auto-service-1.0.1.jar;%APP_HOME%\lib\auto-service-annotations-1.0.1.jar;%APP_HOME%\lib\auto-common-1.2.jar;%APP_HOME%\lib\guava-31.1-jre.jar;%APP_HOME%\lib\netty-handler-proxy-4.1.60.Final.jar;%APP_HOME%\lib\netty-codec-http-4.1.92.Final.jar;%APP_HOME%\lib\netty-transport-native-epoll-4.1.92.Final.jar;%APP_HOME%\lib\netty-transport-native-epoll-4.1.92.Final-linux-x86_64.jar;%APP_HOME%\lib\netty-transport-classes-epoll-4.1.92.Final.jar;%APP_HOME%\lib\netty-transport-native-kqueue-4.1.92.Final.jar;%APP_HOME%\lib\netty-transport-native-kqueue-4.1.92.Final-osx-x86_64.jar;%APP_HOME%\lib\netty-transport-classes-kqueue-4.1.92.Final.jar;%APP_HOME%\lib\netty-handler-4.1.92.Final.jar;%APP_HOME%\lib\netty-transport-native-unix-common-4.1.92.Final.jar;%APP_HOME%\lib\netty-codec-socks-4.1.60.Final.jar;%APP_HOME%\lib\netty-codec-4.1.92.Final.jar;%APP_HOME%\lib\netty-transport-4.1.92.Final.jar;%APP_HOME%\lib\netty-buffer-4.1.92.Final.jar;%APP_HOME%\lib\netty-resolver-4.1.92.Final.jar;%APP_HOME%\lib\netty-common-4.1.92.Final.jar;%APP_HOME%\lib\opentelemetry-exporter-logging-1.26.0.jar;%APP_HOME%\lib\opentelemetry-sdk-extension-autoconfigure-1.26.0-alpha.jar;%APP_HOME%\lib\opentelemetry-sdk-extension-autoconfigure-spi-1.26.0.jar;%APP_HOME%\lib\opentelemetry-sdk-1.26.0.jar;%APP_HOME%\lib\opentelemetry-sdk-trace-1.26.0.jar;%APP_HOME%\lib\opentelemetry-sdk-metrics-1.26.0.jar;%APP_HOME%\lib\opentelemetry-sdk-logs-1.26.0-alpha.jar;%APP_HOME%\lib\opentelemetry-sdk-common-1.26.0.jar;%APP_HOME%\lib\opentelemetry-semconv-1.26.0-alpha.jar;%APP_HOME%\lib\opentelemetry-extension-incubator-1.26.0-alpha.jar;%APP_HOME%\lib\opentelemetry-api-logs-1.26.0-alpha.jar;%APP_HOME%\lib\opentelemetry-api-events-1.26.0-alpha.jar;%APP_HOME%\lib\opentelemetry-api-1.26.0.jar;%APP_HOME%\lib\opentelemetry-context-1.26.0.jar;%APP_HOME%\lib\byte-buddy-1.14.4.jar;%APP_HOME%\lib\commons-exec-1.3.jar;%APP_HOME%\lib\failureaccess-1.0.1.jar;%APP_HOME%\lib\listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar;%APP_HOME%\lib\jsr305-3.0.2.jar;%APP_HOME%\lib\checker-qual-3.12.0.jar;%APP_HOME%\lib\error_prone_annotations-2.11.0.jar;%APP_HOME%\lib\j2objc-annotations-1.3.jar;%APP_HOME%\lib\failsafe-3.3.1.jar;%APP_HOME%\lib\jakarta.activation-1.2.2.jar


@rem Execute eqx
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %EQX_OPTS%  -classpath "%CLASSPATH%" com.tvd.eqx.WebServer %*

:end
@rem End local scope for the variables with windows NT shell
if %ERRORLEVEL% equ 0 goto mainEnd

:fail
rem Set variable EQX_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
set EXIT_CODE=%ERRORLEVEL%
if %EXIT_CODE% equ 0 set EXIT_CODE=1
if not ""=="%EQX_EXIT_CONSOLE%" exit %EXIT_CODE%
exit /b %EXIT_CODE%

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
