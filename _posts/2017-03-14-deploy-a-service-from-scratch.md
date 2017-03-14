---
layout: post
title: 'Deploy a service from scratch to monitor data gathering'
date: 2017-03-14
---

Sometimes we want to be sure that your services are running and didn't terminate for whatever reason. In those cases, normally I use tools like [Monit](https://mmonit.com/monit/) and it is fair enough.

This case is a bit more complicated though. The service I want to monitor queries a REST API and stores some real time data in an database, building a historic. By ensuring that the service is up I know the service *tries* to build the historic but not if it actually does. What if there is something that keeps some data from being stored? It could be a bug in the data gathering code, some network problems, etc. Imagine discovering after some weeks that your data was just not saved in the database.

In order to check that the data is effectively being stored in the database, I created a small service that reads the last timestamp inserted and just outputs "success" if it is recent or "failure" otherwise. I will then monitor this service with monit, checking that the result is successful. Here is what I did:

1. Create maven project. In the command line:


   ~~~
	$ mvn archetype:generate
   ~~~

1. Configure the pom.xml to tell Maven to package the project as .war file and to use some dependencies: Servlet API and a library to connect to the database.


   ~~~xml
	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
		<modelVersion>4.0.0</modelVersion>

		<artifactId>dbstatus</artifactId>
		<packaging>war</packaging>

		<name>dbstatus</name>

		<properties>
			<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
		</properties>

		<dependencies>
			<dependency>
				<groupId>javax.servlet</groupId>
				<artifactId>javax.servlet-api</artifactId>
				<version>3.0.1</version>
				<scope>provided</scope>
			</dependency>
			<dependency>
				<groupId>org.fergonco.traffic</groupId>
				<artifactId>jpa</artifactId>
				<version>1.0-SNAPSHOT</version>
			</dependency>
		</dependencies>

	</project>

   ~~~

4. Some tools are unhappy if there is no web.xml file. It will be just empty since our servlet will be declared with annotations:

   ~~~xml
	<web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://java.sun.com/xml/ns/javaee 
		      http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
		version="3.0">
	</web-app>
   ~~~
		
5. Create and implement the servlet. Basically it obtains the maximum value of the timestamp field from the database and checks it against *now*. If the difference is greater than a certain amount of time, output a "failure", else output a "success":

   ~~~java
	[...]
	@WebServlet("/dbstatus")
	public class StatusServlet extends HttpServlet {
		private static final long serialVersionUID = 1L;

		@Override
		protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
			String answer = "weather: $weatherStatus\ntransport: $transportStatus";
			Date nowDate = new Date();
			long now = nowDate.getTime();

			EntityManager em = DBUtils.getEntityManager();
			Long lastWeatherCondition = (Long) em.createNativeQuery("select max(\"timestamp\") from app.WeatherConditions;")
					.getSingleResult();
			String weatherStatus = (now - lastWeatherCondition > 5 * 60 * 60 * 1000) ? "fail" : "success";

			Long lastTransportShift = (Long) em.createNativeQuery("select max(\"timestamp\") from app.Shift;")
					.getSingleResult();
			Calendar calendar = GregorianCalendar.getInstance();
			calendar.setTime(nowDate);
			int hour = calendar.get(Calendar.HOUR_OF_DAY);
			String transportStatus = ((hour > 7) && (now - lastTransportShift > 60 * 60 * 1000)) ? "fail" : "success";

			answer = answer.replace("$weatherStatus", weatherStatus);
			answer = answer.replace("$transportStatus", transportStatus);
			resp.getWriter().write(answer);
		}

	}
   ~~~

6. Create a Dockerfile. Nothing special here, just use Tomcat image over Alpine and add our .war:


   ~~~
	FROM tomcat:7-jre8-alpine
	ADD target/segment-speeds-service-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/segment-speeds.war
   ~~~

7. Create a docker image and push to docker hub


   ~~~
	mvn package
	docker build . -t fergonco/traffic-viewer-dbstatus
	docker push fergonco/traffic-viewer-dbstatus
   ~~~

8. Pull the image on the server and run. We are just linking the dockers with --link which is such a quick, dirty and [legacy](https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/) way to link docker containers. I'll move on to something else some day.


   ~~~
	docker pull fergonco/traffic-viewer-dbstatus
	docker run -d -p $PORT:8080 --link $PG:pg -e TRAFFIC_VIEWER_DB_URL=jdbc:postgresql://pg:5432/$DB -e TRAFFIC_VIEWER_DB_USER=$USERNAME -e TRAFFIC_VIEWER_DB_PASSWORD=$PASSWORD --name traffic-viewer-dbstatus fergonco/traffic-viewer-dbstatus
   ~~~

9. Check manually the [service](http://fergonco.org/dbstatus/).

1. Add some monit configuration to check that the output of our service gives us the right output:


   ~~~
	check host border-rampage with address fergonco.org
	    if failed        
		port 80 protocol http
		request "/dbstatus/" with content = "weather: success\ntransport: success"
	    then alert
   ~~~

That's it. Some info about the context of this work coming soon :)



