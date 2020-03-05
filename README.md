# Distributed Apache Cassandra in Raspberry PI cluster
This repository describes the use of custom Docker images for running Apache Cassandra in a cluster of Raspberry Pi's. The cluster management tool used is Docker Swarm.

- **Cassandra version: 3.11**
- **Architecture: armv7l**
- **The custom Dockerfile in this repository is based on the official Cassandra Dockerfile on the Docker Hub**

# Deploy process

## 1. Network
In a swarm manager node, execute the command line bellow to create a new overlay network named "cassandra-net":

```
docker network create -d overlay cassandra-net
```

## 2. Swarm Nodes Labels
Set the type label in nodes to define groups for service scale command:

```
docker node update --label-add type=(slave or master) node-id
```
## 3. Storage
Create the directories that will be mapped as volumes to the Cassandra services data storage.

The default storage path in the host to the Cassandra stack is: **/mnt/storage/cassandra**.
The Docker volume must be map the **/var/lib/cassandra** directory of the container to the host directory, as follows:

```
    volumes:
      - /storage/dir/host:/var/lib/cassandra 
```

## 4. Deploy Cassandra stack
To deploy the stack defined in the compose file, execute:

```
docker stack deploy -c docker-compose.yml cassandra
```

Two Docker services will be launched, the first being the Cassandra node responsible for the seeds (service **seed**) and a non-seed node (service **node**). 

Make sure you have clean storage before perform deploy.

## 5. Scale Cassandra service
To scale the number of Cassandra services, execute the command below, passing the number of replicas (example: 3):
```
docker service scale cassandra_node=3
```
As the stack is configured to run only one instance of the Cassandra service (task) per node, it is only possible to scale to a number of replicas equal to the number of available nodes in the cluster.

# Configurations:

### Exposed Ports
| Port | Usage                                       |
| ---- |:-------------:                              |
| 7000 | Unencrypted Intra-node gossip communication |
| 7001 | TLS Intra-node gossip communication         |
| 9042 | CQL native service                          |
| 7199 | JMX server                                  |
| 9160 | Thrift service                              |

### Compose environments
Some configurations are adjustable and provided as environment variables. Default value to some variables are defined in docker-compose.yaml. Those variables are:

| Property Name               | Usage                                                                                                 |
| ----------------------------|:-------------:                                                                                        |
| CASSANDRA_CLUSTER_NAME      | The universal name across all nodes in the cluster                                                    |
| CASSANDRA_NUM_TOKENS        | Number of tokens for this node.                                                                       |
| MAX_HEAP_SIZE               | Heap size settings (Xms and Xmx)                                                                      |
| HEAP_NEW_SIZE               | Size for young generation (Xmn).                                                                      |
| SEEDS_SERVICE               | Name of the seeds service, used to find the ip of the seed node in the swarm network.                 |
| TASK_NAME                   | Name of the task representing each service instance, used to synchronize the boot order               |
| WAIT_TIME                   | Wait time that each task must be wait before starting the cluster join process                        |


# Management tips

## Cassandra cluster status
To view the cluster status, among other Cassandra cluster management tasks, use the **nodetool** utility.

```
docker exec -t container-id nodetool status
```
## CQLSH connection
To perform queries in the Cassandra database you can use cqlsh directly, passing the service port and ip of the node that exposes the service:

```
cqlsh 15.0.0.1 -p9042 --cqlversion=3.4.4
```

## Service logs

To view Cassandra service runtime log incrementally (like tail -f):

```
docker service logs -f (service-name or service-id)
```
* is the same for task-name or task-id

# References
- https://github.com/docker-library/docs/tree/master/cassandra
- https://github.com/mcfongtw/docker-rpi-cassandra
- https://github.com/docker-library/cassandra/issues/94