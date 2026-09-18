# umd-fcrepo-messaging

UMD Libraries Fedora Messaging Infrastructure

## Key Components

* [ActiveMQ] is the message broker
* [Camel] configures message routing

## Related Repositories

* [umd-camel-processors]
* [umd-fcrepo-auth-utils]

## Camel Routes

[Route definitions](activemq/conf/camel) (written in the
[Camel Spring XML DSL]).

## Docker Image

This repository contains a [Dockerfile](Dockerfile) for creating a 
Docker image, and a [compose.yml](compose.yml) for quickly running the 
application.

### Volumes

| Mount point         | Purpose                                           |
|---------------------|---------------------------------------------------|
| `/var/opt/activemq` | Persistent data for ActiveMQ (queues, logs, etc.) |
| `/var/log/fixity`   | Fixity check logs (see the [fixity Camel route])  |

### Ports

| Port number | Purpose                    |
|-------------|----------------------------|
| 8161        | ActiveMQ web admin console |
| 11099       | [JMX] remote connection    |
| 61613       | [STOMP] messaging          |
| 61616       | [OpenWire] messaging       |

### Environment Variables

There are a number of environment variables that are used to configure the
umd-fcrepo-messaging application. Most of these have defaults defined in the
Docker compose.yml file. The only value that needs to be set separately in an
`.env` file is `JWT_SECRET`. This should be the same `JWT_SECRET` as used by
the [umd-fcrepo] development stack.

The defaults in `compose.yml` are chosen assuming the container is running on
the same network as the other services in the [umd-fcrepo] development stack.
If you are running this application outside of that stack, you will need to
adjust the URLs.

| Name                           | Default in compose.yml                       |
|--------------------------------|----------------------------------------------|
| `AUDIT_DB_HOST`                | audit-db                                     |
| `AUDIT_DB_PORT`                | 5432                                         |
| `AUDIT_DB_NAME`                | fcrepo_audit                                 |
| `AUDIT_DB_USERNAME`            | camel                                        |
| `AUDIT_DB_PASSWORD`            | camel                                        |
| `AUDIT_EVENT_BASE_URI`         | http://fcrepo-local:8080/fcrepo/audit/       |
| `AUDIT_TRIPLESTORE_UPDATE_URI` | http://fuseki:3030/fcrepo-audit/update       |
| `BATCH_USER`                   | plastron                                     |
| `CAMEL_LOG_LEVEL`              | INFO                                         |
| `FIXITY_LOG_DIR`               | /tmp                                         |
| `INDEX_TRIPLESTORE_UPDATE_URI` | http://fuseki:3030/fedora4/update            |
| `JWT_SECRET`                   |                                              |
| `LOG_LEVEL`                    | WARN                                         |
| `REPO_EXTERNAL_URL`            | http://fcrepo-local:8080/fcrepo/rest         |
| `REPO_INTERNAL_URL`            | http://webapp:8080/fcrepo/rest               |
| `REPO_OPENWIRE_ENDPOINT`       | tcp://webapp:61616                           |
| `SMTP_SERVER`                  | mail:8025                                    |
| `SOLR_UPDATE_ENDPOINT`         | http://solr-fcrepo:8983/solr/fcrepo/update   |
| `SOLRIZER_ENDPOINT`            | http://solrizer:5000/doc                     |
| `UMD_LIB_LOG_LEVEL`            | DEBUG                                        |

### Build

Use Docker Compose to build and run the application.

```zsh
docker compose build
```

```zsh
docker compose up -d
```

The ActiveMQ web admin console will be at <http://localhost:8161/admin/>

* [STOMP] server and port: `localhost:61613`
* [OpenWire] server and port: `localhost:61616`

## Documentation

To generate Markdown documentation with PlantUML diagrams of the routes, run

```zsh
mvn antrun:run
```

This will generate a *.md file for each *.xml file in the Camel routes
configuration. Generated documentation will be in the `docs/routing`
directory.

## History

This code comes from the
[activemq](https://github.com/umd-lib/umd-fcrepo-docker/tree/1.0.1/activemq)
subdirectory of the [umd-fcrepo-docker] project at the 1.0.1 release.

## License

See the [LICENSE](LICENSE) file for license rights and limitations (Apache 2.0).


[ActiveMQ]: https://activemq.apache.org/components/classic/
[Camel]: https://camel.apache.org/
[Camel Spring XML DSL]: https://camel.apache.org/components/latest/spring-summary.html 
[umd-fcrepo-docker]: https://github.com/umd-lib/umd-fcrepo-docker
[fixity Camel route]: activemq/conf/camel/fixity.xml
[STOMP]: https://stomp.github.io/
[OpenWire]: https://activemq.apache.org/openwire.html
[umd-camel-processors]: https://github.com/umd-lib/umd-camel-processors
[umd-fcrepo-auth-utils]: https://github.com/umd-lib/umd-fcrepo-auth-utils
[JMX]: https://activemq.apache.org/jmx#activemq-mbeans-reference
