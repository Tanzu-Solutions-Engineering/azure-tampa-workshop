# Overview

Now that we are familiar with Spring Initializr, let's create a project and add some more features. In this lab we will be creating a new Spring Boot project and adding Respository and Rest annotations to give our application more funcationality.

## Create a Spring Boot Project
 
1.  Browse to [Spring Initializr](https://start.spring.io)

2.  Generate a `Maven Project` with `Java 8` and Spring Boot `1.5.12`

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
    `CN-Workshop/labs/cloud-native-spring`

    ```sh
    CN-Workshop $ cd labs
    CN-Workshop/labs $ cp ~/Downloads/cloud-native-spring.zip .
    CN-Workshop/labs $ unzip cloud-native-spring.zip
    CN-Workshop/labs $ cd cloud-native-spring
    ```

    Your directory structure should now look like:

    ```sh
    CN-Workshop:
    ├── labs
    │   ├── cloud-native-spring
    ```

7.  In the resources package, rename `application.properties` to `application.yml`

    Spring Boot uses the `application.properties`/`application.yml` file
    to specify various properties which configure the behavior of
    your application. By default, [Spring Initializr](start.spring.io)
    creates a project with an `application.properties` file, however,
    throughout this workshop we will be [using YAML instead of
    Properties](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html#boot-features-external-config-yaml).

    ```sh
    CN-Workshop/labs/cloud-native-spring $ mv src/main/resources/application.properties src/main/resources/application.yml
    ```

8.  Import the project’s pom.xml into your editor/IDE of choice.

**Tip**

**Spring Tool Suite Import Help**
1. Navigate to: `File -> Import… -> Maven -> Existing Maven Projects`
1. On the Import Maven Projects page, *Browse* to: `CN-Workshop/labs/cloud-native-spring`

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

        CN-Workshop/labs/cloud-native-spring $ ./mvnw spring-boot:run

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

    `CN-Workshop/labs/cloud-native-spring $ ./mvnw package`

2.  Create a Cloud Foundry application manifest.

    Defining a `manifest.yml` is a very useful way of specifying
    sensible defaults for your application when deploying to
    Cloud Foundry.

    `CN-Workshop/labs/cloud-native-spring $ touch manifest.yml`

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
    CN-Workshop/labs/cloud-native-spring $ cf push
    Using manifest file /Users/someuser/git/CN-Workshop/labs/cloud-native-spring/manifest.yml
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

# RestRepository

In this section we’ll utilize Spring Boot, Spring Data, and Spring Data REST to create a fully-functional hypermedia-driven RESTful web service. We’ll then deploy it to Pivotal Cloud Foundry.

## Create a Hypermedia-Driven RESTful Web Service with Spring Data REST

This application will create a simple reading list by asking for books you have read and storing them in a simple relational repository. We’ll continue building upon the Spring Boot application we build in the Spring Boot lab. The first stereotype we will need is the domain model itself, which is `City`.

## Add the `City` domain object

1.  Create the package `io.pivotal.cloudnativespring.domain` and in that package create the class `City` using the following Java Persistence API code, which represents cities based on postal codes, global coordinates, etc.
    
    **cloud-native-spring/src/main/java/io/pivotal/cloudnativespring/domain/City.java.**

    ```java
    package io.pivotal.cloudnativespring.domain;

    import java.io.Serializable;

    import javax.persistence.Column;
    import javax.persistence.Entity;
    import javax.persistence.GeneratedValue;
    import javax.persistence.Id;
    import javax.persistence.Table;

    @Entity
    @Table(name="city")
    public class City implements Serializable {
        private static final long serialVersionUID = 1L;

        @Id
        @GeneratedValue
        private long id;

        @Column(nullable = false)
        private String name;

        @Column(nullable = false)
        private String county;

        @Column(nullable = false)
        private String stateCode;

        @Column(nullable = false)
        private String postalCode;

        @Column
        private String latitude;

        @Column
        private String longitude;

        public String getName() { return name; }

        public void setName(String name) { this.name = name; }

        public String getPostalCode() { return postalCode; }

        public void setPostalCode(String postalCode) { this.postalCode = postalCode; }

        public long getId() { return id; }

        public void setId(long id) { this.id = id; }

        public String getStateCode() { return stateCode; }

        public void setStateCode(String stateCode) { this.stateCode = stateCode; }

        public String getCounty() { return county; }

        public void setCounty(String county) { this.county = county; }

        public String getLatitude() { return latitude; }

        public void setLatitude(String latitude) { this.latitude = latitude; }

        public String getLongitude() { return longitude; }

        public void setLongitude(String longitude) { this.longitude = longitude; }
    }
    ```

2.  Create the package `io.pivotal.cloudnativespring.repositories` and in that package create the interface `CityRepository` using the following code.
    
    **cloud-native-spring/src/main/java/io/pivotal/cloudnativespring/repositories/CityRepository.java.**

    ```java
    package io.pivotal.cloudnativespring.repositories;

    import org.springframework.data.repository.PagingAndSortingRepository;
    import org.springframework.data.rest.core.annotation.RepositoryRestResource;

    import io.pivotal.cloudnativespring.domain.City;

    @RepositoryRestResource(collectionResourceRel = "cities", path = "cities")
    public interface CityRepository extends PagingAndSortingRepository<City, Long> {
    }
    ```

3.  Add JPA and REST Repository support to the `io.pivotal.cloudnativespring.CloudNativeSpringApplication` Spring Boot Application class.
    
    **cloud-native-spring/src/main/java/io/pivotal/cloudnativespring/CloudNativeSpringApplication.java.**

    ```java
    package io.pivotal.cloudnativespring;

    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    import org.springframework.web.bind.annotation.RequestMapping;
    import org.springframework.web.bind.annotation.RestController;

    // Add these imports:
    import org.springframework.context.annotation.Import;
    import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
    import org.springframework.data.rest.webmvc.config.RepositoryRestMvcConfiguration;

    @SpringBootApplication
    @RestController
    @EnableJpaRepositories // <---- And this
    @Import(RepositoryRestMvcConfiguration.class) // <---- And this
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

    ```sh
    CN-Workshop/labs/cloud-native-spring $ ./mvnw spring-boot:run
    ```

2.  Access the application using `curl` or your web browser using the newly added REST repository endpoint at <http://localhost:8080/cities>. You’ll see that the primary endpoint automatically exposes the ability to page, size, and sort the response JSON.

    ```sh
    $ curl -i http://localhost:8080/cities
    HTTP/1.1 200
    X-Application-Context: application
    Content-Type: application/hal+json;charset=UTF-8
    Transfer-Encoding: chunked
    Date: Thu, 02 Nov 2017 04:10:15 GMT

    {
      "_embedded" : {
        "cities" : [ ]
      },
      "_links" : {
        "self" : {
          "href" : "http://localhost:8080/cities{?page,size,sort}",
          "templated" : true
        },
        "profile" : {
          "href" : "http://localhost:8080/profile/cities"
        }
      },
      "page" : {
        "size" : 20,
        "totalElements" : 0,
        "totalPages" : 0,
        "number" : 0
      }
    }
    ```

So what have you done? Created four small classes (including our unit test) and one build file, resulting in a fully-functional REST microservice. The application’s `DataSource` is created automatically by Spring Boot using the in-memory database because no other `DataSource`
was detected in the project. Next we’ll import some data.

## Importing Data

1.  Download this [import.sql](https://raw.githubusercontent.com/Pivotal-Field-Engineering/CN-Workshop/master/labs/lab02/import.sql) file and add it to `src/main/resources` folder. This is a rather large dataset containing all of the postal codes in the United States and its territories. This file will automatically be picked up by Hibernate and imported into the in-memory database.

    ```sh
    CN-Workshop/labs/cloud-native-spring $ cp ~/Downloads/import.sql src/main/resources/.
    ```

2.  Restart the application.

    ```sh
    CN-Workshop/labs/cloud-native-spring $ ./mvnw spring-boot:run
    ```

3.  Access the application again: <http://localhost:8080/cities>. Notice the appropriate hypermedia is included for `next`, `previous`, and `self`. You can also select pages and page size by utilizing `?size=n&page=n` on the URL string. Finally, you can sort the data utilizing `?sort=fieldName` (replace fieldName with a cities attribute).

    ```sh
    $ curl -i localhost:8080/cities
    HTTP/1.1 200
    X-Application-Context: application
    Content-Type: application/hal+json;charset=UTF-8
    Transfer-Encoding: chunked
    Date: Thu, 02 Nov 2017 11:30:26 GMT

    {
      "_embedded" : {
        "cities" : [ {
          "name" : "HOLTSVILLE",
          "county" : "SUFFOLK",
          "stateCode" : "NY",
          "postalCode" : "00501",
          "latitude" : "+40.922326",
          "longitude" : "-072.637078",
          "_links" : {
            "self" : {
              "href" : "http://localhost:8080/cities/1"
            },
            "city" : {
              "href" : "http://localhost:8080/cities/1"
            }
          }
        },

        // ...

        {
          "name" : "CASTANER",
          "county" : "LARES",
          "stateCode" : "PR",
          "postalCode" : "00631",
          "latitude" : "+18.269187",
          "longitude" : "-066.864993",
          "_links" : {
            "self" : {
              "href" : "http://localhost:8080/cities/20"
            },
            "city" : {
              "href" : "http://localhost:8080/cities/20"
            }
          }
        } ]
      },
      "_links" : {
        "first" : {
          "href" : "http://localhost:8080/cities?page=0&size=20"
        },
        "self" : {
          "href" : "http://localhost:8080/cities{?page,size,sort}",
          "templated" : true
        },
        "next" : {
          "href" : "http://localhost:8080/cities?page=1&size=20"
        },
        "last" : {
          "href" : "http://localhost:8080/cities?page=2137&size=20"
        },
        "profile" : {
          "href" : "http://localhost:8080/profile/cities"
        }
      },
      "page" : {
        "size" : 20,
        "totalElements" : 42741,
        "totalPages" : 2138,
        "number" : 0
      }
    }
    ```

4.  Try the following URL Paths in your browser or `curl` to see how the application behaves:

    <http://localhost:8080/cities?size=5>

    <http://localhost:8080/cities?size=5&page=3>

    <http://localhost:8080/cities?sort=postalCode,desc>

Next we’ll add searching capabilities.

## Adding Search

1.  Let’s add some additional finder methods to `CityRepository`:

    **cloud-native-spring/src/main/java/io/pivotal/cloudnativespring/repositories/CityRepository.java.**

    ```java
    @RestResource(path = "name", rel = "name")
    Page<City> findByNameIgnoreCase(@Param("q") String name, Pageable pageable);

    @RestResource(path = "nameContains", rel = "nameContains")
    Page<City> findByNameContainsIgnoreCase(@Param("q") String name, Pageable pageable);

    @RestResource(path = "state", rel = "state")
    Page<City> findByStateCodeIgnoreCase(@Param("q") String stateCode, Pageable pageable);

    @RestResource(path = "postalCode", rel = "postalCode")
    Page<City> findByPostalCode(@Param("q") String postalCode, Pageable pageable);
    ```

2.  Run the application

    ```sh
    CN-Workshop/labs/cloud-native-spring $ ./mvnw spring-boot:run
    ```

3.  Access the application again. Notice that hypermedia for a new `search` endpoint has appeared.

    ```sh
    ~ » curl -i localhost:8080/cities
    HTTP/1.1 200
    X-Application-Context: application
    Content-Type: application/hal+json;charset=UTF-8
    Transfer-Encoding: chunked
    Date: Thu, 02 Nov 2017 11:45:10 GMT

    {
      // ...

      "_links" : {
        "first" : {
          "href" : "http://localhost:8080/cities?page=0&size=20"
        },
        "self" : {
          "href" : "http://localhost:8080/cities{?page,size,sort}",
          "templated" : true
        },
        "next" : {
          "href" : "http://localhost:8080/cities?page=1&size=20"
        },
        "last" : {
          "href" : "http://localhost:8080/cities?page=2137&size=20"
        },
        "profile" : {
          "href" : "http://localhost:8080/profile/cities"
        },
        "search" : {
          "href" : "http://localhost:8080/cities/search"
        }
      },
      "page" : {
        "size" : 20,
        "totalElements" : 42741,
        "totalPages" : 2138,
        "number" : 0
      }
    }
    ```

4.  Access the new `search` endpoint: <http://localhost:8080/cities/search>

    ```sh
    $ curl -i localhost:8080/cities/search
    HTTP/1.1 200
    X-Application-Context: application
    Content-Type: application/hal+json;charset=UTF-8
    Transfer-Encoding: chunked
    Date: Thu, 02 Nov 2017 11:49:15 GMT

    {
      "_links" : {
        "postalCode" : {
          "href" : "http://localhost:8080/cities/search/postalCode{?q,page,size,sort}",
          "templated" : true
        },
        "name" : {
          "href" : "http://localhost:8080/cities/search/name{?q,page,size,sort}",
          "templated" : true
        },
        "state" : {
          "href" : "http://localhost:8080/cities/search/state{?q,page,size,sort}",
          "templated" : true
        },
        "nameContains" : {
          "href" : "http://localhost:8080/cities/search/nameContains{?q,page,size,sort}",
          "templated" : true
        },
        "self" : {
          "href" : "http://localhost:8080/cities/search"
        }
      }
    }
    ```

    Note that we now have new search endpoints for each of the finders that we added.

5.  Try a few of these endpoints. Feel free to substitute your own values for the parameters.

    <http://localhost:8080/cities/search/postalCode?q=75202>

    <http://localhost:8080/cities/search/name?q=Boston>

    <http://localhost:8080/cities/search/nameContains?q=Fort&size=1>

# Pushing to Cloud Foundry

1.  Build the application

    ```sh
    CN-Workshop/labs/cloud-native-spring $ ./mvnw package
    ```

2.  You should already have an application manifest, `manifest.yml`, created in lab 1; this can be reused. You’ll want to add a timeout param so that our service has enough time to initialize with its data loading:

    **cloud-native-spring/manifest.yml.**

    ```yaml
    ---
    applications:
    - name: cloud-native-spring
      random-route: true
      memory: 768M
      path: target/cloud-native-spring-0.0.1-SNAPSHOT.jar
      timeout: 180 # to give time for the data to import
      env:
        JAVA_OPTS: -Djava.security.egd=file:///dev/urandom
    ```

3.  Push to Cloud Foundry:

    ```sh
    CN-Workshop/labs/cloud-native-spring $ cf push
    Using manifest file /Users/someuser/git/CN-Workshop/labs/cloud-native-spring/manifest.yml
    ...
    Showing health and status for app cloud-native-spring in org user-org / space user-space as user@example.com...
    OK

    requested state: started
    instances: 1/1
    usage: 768M x 1 instances
    urls: cloud-native-spring-liqxfuds.cfapps.io
    last uploaded: Thu Nov 2 11:53:29 UTC 2017
    stack: cflinuxfs2
    buildpack: java_buildpack

          state     since                    cpu    memory           disk           details
    #0   running   2017-11-02 06:54:35 AM   0.0%   157.3M of 768M   158.7M of 1G
    ```

4.  Access the application at the random route provided by CF:

    ```sh
    $ curl -i https://cloud-native-spring-<random>.cfapps.io/cities
    ```


