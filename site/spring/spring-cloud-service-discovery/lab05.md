# Overview

In this lab we’ll utilize Spring Boot and Spring Cloud to allow our application to register itself with a service registry. To do this we’ll also need to provision an instance of a Service Registry using Pivotal Cloud Foundry Spring Cloud Services, which is based on [Eureka](https://github.com/Netflix/eureka), Netflix’s Service Discovery server and client. We’ll also add a simple client application that looks up our application from the Service Registry and makes requests to our `Cities` service.

# Update *Cloud-Native-Spring* Boot Application to Register with Service Registry

1.  These features are added by adding `spring-cloud-services-starter-service-registry` to the classpath. Add the following spring cloud services to your Maven project dependencies:

    **cloud-native-spring/pom.xml.**

    ```xml
    <dependency>
        <groupId>io.pivotal.spring.cloud</groupId>
        <artifactId>spring-cloud-services-starter-service-registry</artifactId>
    </dependency>
    ```

2.  Thanks to Spring Cloud, instructing your application to register with Service Registry is as simple as adding a single annotation to your app! Add an @EnableDiscoveryClient annotation to the `io.pivotal.cloudnativespring.CloudNativeSpringApplication` class:

    **cloud-native-spring/src/main/java/io/pivotal/cloudnativespring/CloudNativeSpringApplication.java.**

    ```java
    @SpringBootApplication
    @RestController
    @EnableJpaRepositories
    @EnableDiscoveryClient // <---- Add this
    @Import(RepositoryRestMvcAutoConfiguration.class)
    public class CloudNativeSpringApplication {
        [...]
    }
    ```

    Completed:

    ```java
    package io.pivotal.cloudnativespring;

    import org.springframework.beans.factory.annotation.Value;
    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
    import org.springframework.context.annotation.Import;
    import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
    import org.springframework.data.rest.webmvc.config.RepositoryRestMvcConfiguration;
    import org.springframework.web.bind.annotation.RequestMapping;
    import org.springframework.web.bind.annotation.RestController;

    @SpringBootApplication
    @RestController
    @EnableJpaRepositories
    @EnableDiscoveryClient
    @Import(RepositoryRestMvcConfiguration.class)
    public class CloudNativeSpringApplication {

        @Value("${greeting:Hola}")
        private String greeting;

        public static void main(String[] args) {
            SpringApplication.run(CloudNativeSpringApplication.class, args);
        }

        @RequestMapping("/")
        public String hello() {
            return greeting + " World!";
        }
    }
    ```

# Create Spring Cloud Service Registry instance and deploy application

1.  Now that our application is ready to read registry with a Service Registry instance, we need to deploy one! This can be done through Cloud Foundry using the services marketplace. Previously we did this through the Marketplace UI, but this time we will use the Cloud Foundry CLI (though we could also do this through the UI):

    ```sh
    CN-Workshop/labs/cloud-native-spring $ cf create-service p-service-registry standard service-registry
    ```

2.  After you create the service registry instance navigate to your Cloud Foundry *space* in the Apps Manager UI and refresh the page. You should now see the newly create `service-registry` instance. Select the manage link to view the registry dashboard. Note that there are not any registered applications at the moment:

    ![](images/registry1.jpg)

3.  We will now bind our application to our service-registry within our Cloud Foundry deployment manifest. Add the additional reference the services list in our Cloud Foundry manifest:

    **cloud-native-spring/manifest.yml.**

    ```yaml
    services:
    - config-server
    - service-registry # <-- Add this
    ```

    Complete:

    ```yaml
    ---
    applications:
    - name: cloud-native-spring
      random-route: true
      memory: 768M
      path: target/cloud-native-spring-0.0.1-SNAPSHOT.jar
      timeout: 180
      env:
        JAVA_OPTS: -Djava.security.egd=file:///dev/urandom
      services:
      - config-server
      - service-registry
    ```

Deploy and test application
===========================

1.  For the 2nd half of this lab we’ll need our `cloud-native-spring` Maven artifact accessible in our local Maven repository. Rebuild and install the artifact with the following command:

    ```sh
    CN-Workshop/labs/cloud-native-spring $ ./mvnw install
    ```

2.  Push application into Cloud Foundry

    ```sh
    CN-Workshop/labs/cloud-native-spring $ cf push
    ```

3.  If we now test our application URLs we will no change. However, if we view the Service Registry dashboard (accessible from the **Manage** link in Apps Manager) you will see that a service named `CLOUD-NATIVE-SPRING` has registered:

    ![](images/registry2.jpg)

4.  Next we’ll create a simple UI application that will read the service registry to discover the location of our cities REST service and connect.

Create another Spring Boot Project as a Client UI
=================================================

1.  Browse to [Spring Initializr](https://start.spring.io)

2.  Generate a `Maven Project` with `Java` and Spring Boot version 1.5.13  BUILD-SNAPSHOT
    

3.  Fill out the **Project metadata** fields as follows:

    | Group  | Artifact  |
    |---|---|
    | `io.pivotal`  | `cloud-native-spring-ui`  |

4.  In the dependencies section, add each of the following manually:

    -   **Rest Repositories**
    
    -   **Vaadin**

    -   **Actuator**

    -   **Feign**

    -   **Service Registry (PCF)**

5.  Click the *Generate Project* button and your browser will download
    the `cloud-native-spring-ui.zip` file.

6.  Copy then unpack the downloaded zip file to
    `CN-Workshop/labs/cloud-native-spring-ui`

    ```sh
    CN-Workshop/labs $ cp ~/Downloads/cloud-native-spring-ui.zip .
    CN-Workshop/labs $ unzip cloud-native-spring-ui.zip
    CN-Workshop/labs $ cd cloud-native-spring-ui
    ```

    Your directory structure should now look like:

    ```
    CN-Workshop:
    ├── labs
    │   ├── cloud-native-spring
    │   ├── cloud-native-spring-ui
    ```

7.  Rename `application.properties` to `application.yml`

    Spring Boot uses the `application.properties`/`application.yml` file to specify various properties which configure the behavior of your application. By default, Spring Initializr (start.spring.io) creates a project with an `application.properties` file, however, throughout this workshop we will be [using YAML instead of Properties](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html#boot-features-external-config-yaml).

        CN-Workshop/labs/cloud-native-spring-ui $ mv src/main/resources/application.properties src/main/resources/application.yml

8.  Import the project’s pom.xml into your editor/IDE of choice.

9.  Because we politely asked [Spring Initializr](https://start.spring.io) to include **Service Registry (PCF)**, our Maven project has already been configured with the appropriate Spring Cloud Services dependencies:

    **cloud-native-spring-ui/pom.xml.**

    ```xml
    <project>
      [...]
      <properties>
	       <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	       <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
	       <java.version>1.8</java.version>
	       <spring-cloud-services.version>1.6.3.RELEASE</spring-cloud-services.version>
	       <spring-cloud.version>Edgware.SR3</spring-cloud.version>
	       <vaadin.version>8.3.1</vaadin.version>
	   </properties>
   
      <dependencies>
      [...]
      <dependency>
          <groupId>io.pivotal.spring.cloud</groupId>
          <artifactId>spring-cloud-services-starter-service-registry</artifactId>
      </dependency>
      [...]
      </dependencies>

      <dependencyManagement>
          <dependencies>
             <dependency>
                 <groupId>org.springframework.cloud</groupId>
                 <artifactId>spring-cloud-dependencies</artifactId>
                 <version>${spring-cloud.version}</version>
                 <type>pom</type>
                 <scope>import</scope>
             </dependency>
             <dependency>
                 <groupId>com.vaadin</groupId>
                 <artifactId>vaadin-bom</artifactId>
                 <version>${vaadin.version}</version>
                 <type>pom</type>
                 <scope>import</scope>
             </dependency>
             <dependency>
                 <groupId>io.pivotal.spring.cloud</groupId>
                 <artifactId>spring-cloud-services-dependencies</artifactId>
                 <version>${spring-cloud-services.version}</version>
                 <type>pom</type>
                 <scope>import</scope>
              </dependency>
              </dependencies>
        </dependencyManagement>
        [...]
    </project>
    ```

10. To get a bit of code reuse, we’ll be using the `City` domain object from our main `cloud-native-spring` Spring Boot application. We don’t want to pull in any of the annotations. You can delete them.
   

11. Finally, for consistency’s sake, we’ll produce an exec classified artifact as we did for cloud-native-spring. Your build section should now include:

    ```xml
    <project>
        [...]
        <build>
        <plugins>
            [...]
            <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <executions>
                <execution>
                <goals>
                    <goal>build-info</goal>
                </goals>
                </execution>
            </executions>
            <configuration>
                <classifier>exec</classifier>
            </configuration>
            </plugin>
            [...]
        </plugins>
        </build>
        [...]
    </project>
    ```

Creating the UI
===============

1.  Since this UI is going to consume REST services, its an awesome opportunity to use Feign. Feign will handle **ALL** the work of invoking our services and marshalling/unmarshalling JSON into domain objects. We’ll add a Feign Client interface into our app. Take note of how Feign references the downstream service; its only the name of the service it will lookup from Service Registry.

    Add the following interface declaration to the
    `CloudNativeSpringUiApplication` class:

    ```java
    @FeignClient("cloud-native-spring")
    public interface CityClient {
        @GetMapping(value = "/cities", consumes = "application/hal+json")
        Resources<City> getCities();
    }
    ```

    We’ll also need to add a few annotations to our boot application:

    ```java
    @SpringBootApplication
    @EnableFeignClients  // <---- Add this
    @EnableDiscoveryClient  // <---- And this
    public class CloudNativeSpringUiApplication {
    ```

    Completed:

    ```java
    package io.pivotal.cloudnativespringui;

    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
    import org.springframework.cloud.netflix.feign.EnableFeignClients;
    import org.springframework.cloud.netflix.feign.FeignClient;
    import org.springframework.hateoas.Resources;
    import org.springframework.web.bind.annotation.GetMapping;

    import io.pivotal.cloudnativespring.domain.City;

    @SpringBootApplication
    @EnableFeignClients
    @EnableDiscoveryClient
    public class CloudNativeSpringUiApplication {

        public static void main(String[] args) {
            SpringApplication.run(CloudNativeSpringUiApplication.class, args);
        }

        @FeignClient("cloud-native-spring")
        public interface CityClient {

            @GetMapping(value = "/cities", consumes = "application/hal+json")
            Resources<City> getCities();
        }
    }
    ```

2.  Next we’ll create a Vaadin UI for rendering our data. The point of this workshop isn’t to go into detail on creating UIs; for now suffice to say that Vaadin is a great tool for quickly creating User Interfaces. Our UI will consume our Feign client we just created. Create the `io.pivotal.cloudnativespringui.AppUI` class and paste the following code:

    **cloud-native-spring-ui/src/main/java/io/pivotal/cloudnativespringui/AppUI.java.**

    ```java
    package io.pivotal.cloudnativespringui;

    import java.util.ArrayList;
    import java.util.Collection;

    import org.springframework.beans.factory.annotation.Autowired;

    import com.vaadin.annotations.Theme;
    import com.vaadin.server.VaadinRequest;
    import com.vaadin.spring.annotation.SpringUI;
    import com.vaadin.ui.Grid;
    import com.vaadin.ui.UI;

    import io.pivotal.cloudnativespring.domain.City;
    import io.pivotal.cloudnativespringui.CloudNativeSpringUiApplication.CityClient;

    @SpringUI
    @Theme("valo")
    public class AppUI extends UI {

        private final CityClient cityClient;

        private final Grid<City> grid;

        @Autowired
        public AppUI(CityClient client) {
            this.cityClient = client;
            grid = new Grid<>(City.class);
        }

        @Override
        protected void init(VaadinRequest request) {
            setContent(grid);
            grid.setWidth(100, Unit.PERCENTAGE);
            grid.setHeight(100, Unit.PERCENTAGE);
            Collection<City> collection = new ArrayList<>();
            cityClient.getCities().forEach(collection::add);
            grid.setItems(collection);
        }
    }
    ```

3.  We’ll also want to give our UI App a name so that it can register properly with the Service Registry and potentially use cloud config in the future. The `spring-cloud-services-starter-service-registry` dependency pulls in `spring-security`, so we’ll also need to disable security for our sample ui.

    Add the following to your Spring Boot configuration:

    **cloud-native-spring-ui/src/main/resources/application.yml.**

    ```yaml
    spring:
      application:
        name: cloud-native-spring-ui

    security:
      basic:
        enabled: false
    ```

# Deploy and test application

1.  Build the application.

    ```sh
    CN-Workshop/labs/my_work/cloud-native-spring-ui $ ./mvnw package
    ```

2.  Create a Cloud Foundry application manifest:

    ```sh
    CN-Workshop/labs/my_work/cloud-native-spring-ui $ touch manifest.yml
    ```

    Add application metadata:

    ```yaml
    ---
    applications:
    - name: cloud-native-spring-ui
      random-route: true
      memory: 768M
      path: target/cloud-native-spring-ui-0.0.1-SNAPSHOT.jar
      env:
        JAVA_OPTS: -Djava.security.egd=file:///dev/urandom
      services:
      - service-registry
    ```

3.  Push application into Cloud Foundry

    ```sh
    CN-Workshop/labs/my_work/cloud-native-spring-ui $ cf push
    ```

4.  Test your application by navigating to the root URL of the application, which will invoke Vaadin UI. You should now see a table listing the first set of rows returned from the cities microservice:

    ![](images/ui.jpg)

Congratulations! You've created the smallest of microservices!
