# Overview

Spring Boot makes it easy to create stand-alone, production-grade Spring
based Applications that you can "just run". We take an opinionated view
of the Spring platform and third-party libraries so you can get started
with minimum fuss. Most Spring Boot applications need very little Spring
configuration.

## Create a Spring Boot Project

1.  Browse to [Spring Initializr](https://start.spring.io)

2.  Generate a `Maven Project` with `Java` and Spring Boot
    `{spring-boot-version}`

3.  Fill out the **Project metadata** fields as follows:
    
    | Group  | Artifact  |
    |---|---|
    | `io.pivotal`  | `cloud-native-spring`  |


4.  In the dependencies section, add each of the following manually:

    -   **Web**

    -   **Rest Repositories**

    -   **JPA**

    -   **H2**

    -   **Actuator**

5.  Click the *Generate Project* button and your browser will download
    the `cloud-native-spring.zip` file.

6.  Copy then unpack the downloaded zip file to
    `CN-Workshop/labs/my_work/cloud-native-spring`

    ```sh
    CN-Workshop $ mkdir labs/my_work
    CN-Workshop $ cd labs/my_work
    CN-Workshop/labs/my_work $ cp ~/Downloads/cloud-native-spring.zip .
    CN-Workshop/labs/my_work $ unzip cloud-native-spring.zip
    CN-Workshop/labs/my_work $ cd cloud-native-spring
    ```

    Your directory structure should now look like:

    ```sh
    CN-Workshop:
    ├── labs
    │   ├── my_work
    │   │   ├── cloud-native-spring
    ```

7.  Rename `application.properties` to `application.yml`

    Spring Boot uses the `application.properties`/`application.yml` file
    to specify various properties which configure the behavior of
    your application. By default, [Spring Initializr](start.spring.io)
    creates a project with an `application.properties` file, however,
    throughout this workshop we will be [using YAML instead of
    Properties](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html#boot-features-external-config-yaml).

    ```sh
    CN-Workshop/labs/my_work/cloud-native-spring $ mv src/main/resources/application.properties src/main/resources/application.yml
    ```

8.  Import the project’s pom.xml into your editor/IDE of choice.

**Tip**

**Spring Tool Suite Import Help**
1. Navigate to: `File -> Import… -> Maven -> Existing Maven Projects`
1. On the Import Maven Projects page, *Browse* to: `CN-Workshop/labs/my_work/cloud-native-spring`

## Add an Endpoint


1.  Add an `@RestController` annotation to the class
    `CloudNativeSpringApplication`.
    
    **cloud-native-spring/src/main/java/io/pivotal/cloudnativespring/CloudNativeSpringApplication.java.**

    ```java
    package io.pivotal.cloudnativespring;

    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    import org.springframework.web.bind.annotation.RestController;

    @SpringBootApplication
    @RestController
    public class CloudNativeSpringApplication {

        public static void main(String[] args) {
            SpringApplication.run(CloudNativeSpringApplication.class, args);
        }
    }
    ```

2.  Add the following request handler to the class
    `CloudNativeSpringApplication` here
    
    **cloud-native-spring/src/main/java/io/pivotal/cloudnativespring/CloudNativeSpringApplication.java.**

    ```java
    @RequestMapping("/")
    public String hello() {
        return "Hello World!";
    }
    ```

3. Completed

    **cloud-native-spring/src/main/java/io/pivotal/cloudnativespring/CloudNativeSpringApplication.java.**

    ```java
    package io.pivotal.cloudnativespring;

    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    import org.springframework.web.bind.annotation.RequestMapping;
    import org.springframework.web.bind.annotation.RestController;

    @SpringBootApplication
    @RestController
    public class CloudNativeSpringApplication {

        public static void main(String[] args) {
            SpringApplication.run(CloudNativeSpringApplication.class, args);
        }

        @RequestMapping("/")
        public String hello() {
            return "Hello World!";
        }
    }
    ```

## Run the *cloud-native-spring* Application


1.  Run the application using the project’s Maven Wrapper command:

        CN-Workshop/labs/my_work/cloud-native-spring $ ./mvnw spring-boot:run

2.  You should see the application start up an embedded Apache Tomcat
    server on port `8080` (review terminal output):

    ```sh
    2017-11-01 21:41:09.949  INFO 19104 --- [main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat started on port(s): 8080 (http)
    2017-11-01 21:41:09.957  INFO 19104 --- [main] i.p.c.CloudNativeSpringApplication       : Started CloudNativeSpringApplication in 5.694 seconds (JVM running for 9.866)
    ```

3.  View your web application by browsing to <http://localhost:8080>

    **Note**
    
    Already have something running on port `8080`? You can tell Spring Boot to use a different port by specifying the Java System property `-Dserver.port=9999`: `./mvnw spring-boot:run -Dserver.port=9999`

4.  After validating the app is running properly, stop the
    *cloud-native-spring* application by pressing `CTRL + C` in the
    terminal window.

## Deploy *cloud-native-spring* to Pivotal Cloud Foundry

1.  Build the application using the project’s Maven Wrapper command:

    `CN-Workshop/labs/my_work/cloud-native-spring $ ./mvnw package`

2.  Create a Cloud Foundry application manifest.

    Defining a `manifest.yml` is a very useful way of specifying
    sensible defaults for your application when deploying to
    Cloud Foundry.

    `CN-Workshop/labs/my_work/cloud-native-spring $ touch manifest.yml`

    Add application metadata, using a text editor (of choice)

    ```yaml
    applications:
    - name: cloud-native-spring
        random-route: true
        memory: 768M
        path: target/cloud-native-spring-0.0.1-SNAPSHOT.jar
        env:
            JAVA_OPTS: -Djava.security.egd=file:///dev/urandom
    ```

3.  Push the application to Cloud Foundry.

    ```sh
    CN-Workshop/labs/my_work/cloud-native-spring $ cf push
    Using manifest file /Users/someuser/git/CN-Workshop/labs/my_work/cloud-native-spring/manifest.yml
    ...
    Showing health and status for app cloud-native-spring in org user-org / space user-space as user@example.com...
    OK

    requested state: started
    instances: 1/1
    usage: 768M x 1 instances
    urls: cloud-native-spring-liqxfuds.cfapps.io
    last uploaded: Thu Nov 2 03:33:23 UTC 2017
    stack: cflinuxfs2
    buildpack: java_buildpack

            state     since                    cpu    memory          disk           details
    #0   running   2017-11-01 10:34:24 PM   0.0%   92.8M of 768M   152.6M of 1G
    ```

4.  Find the URL created for your app in the health status report and browse to
    your app.

**Congratulations!** You’ve just completed your first Spring Boot
application.
