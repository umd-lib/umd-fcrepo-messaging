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
