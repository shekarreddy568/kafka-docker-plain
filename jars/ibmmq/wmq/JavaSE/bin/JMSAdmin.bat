@echo off

rem ----------------------------------------------
rem  IBM MQ JMS Admin Tool Execution Script
rem  for Windows NT
rem
rem    <copyright 
rem    notice="lm-source-program" 
rem    pids="5724-H72,5655-R36,5655-L82,5724-L26," 
rem    years="2008,2018" 
rem    crc="3635869111" > 
rem    Licensed Materials - Property of IBM  
rem     
rem    5724-H72,5655-R36,5655-L82,5724-L26, 
rem     
rem    (C) Copyright IBM Corp. 2008, 2018 All Rights Reserved.  
rem     
rem    US Government Users Restricted Rights - Use, duplication or  
rem    disclosure restricted by GSA ADP Schedule Contract with  
rem    IBM Corp.  
rem    </copyright> 
rem ----------------------------------------------

setlocal

rem If no explicit installation has been set then default to using current one
if not defined MQ_INSTALLATION_PATH (
  pushd "%~dps0..\..\bin"
  for /f "delims=" %%x in ('.\crtmqenv.exe -x32 -s') do set %%x
  popd
)
cls

rem Use MQ JRE in preference
if defined MQ_JRE_PATH (
  set AMQJAVA="%MQ_JRE_PATH%\bin\java"
) else (
  set AMQJAVA=java
)

rem Redistributable environments
if not defined MQ_JAVA_INSTALL_PATH (
  set MQ_JAVA_INSTALL_PATH=..
)

rem Redistributable environments
if not defined MQ_JAVA_DATA_PATH (
  set MQ_JAVA_DATA_PATH=..\..
)

rem Redistributable environments
if not defined CLASSPATH (
  set AMQCPFLAGS=-classpath ..\lib\com.ibm.mq.allclient.jar
) else (
  set AMQCPFLAGS=
)
 
rem Get the console.encoding to set for JMSAdmin.
rem This is because, with some IBM Windows JDKs and certain codepages,  
rem the System properties file.encoding and console.encoding 
rem have to be the same to avoid corruption of particular special characters.
rem Redistributable environments
for /F %%x in ('%AMQJAVA% %AMQCPFLAGS% com.ibm.msg.client.commonservices.nls.CodepageSetUp') do set X=%%x

%AMQJAVA% %AMQCPFLAGS% -Dfile.encoding=%X% -Dcom.ibm.msg.client.commonservices.log.outputName="%MQ_JAVA_DATA_PATH%\log" -Dcom.ibm.msg.client.commonservices.trace.outputName="%MQ_JAVA_DATA_PATH%\errors" -DMQ_JAVA_INSTALL_PATH="%MQ_JAVA_INSTALL_PATH%" com.ibm.mq.jms.admin.JMSAdmin %1 %2 %3 %4 %5

endlocal
