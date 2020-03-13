# Description
Basic infrastructure with all the components needed for a modern microservices environment
The idea is that you run a simple command, and automagically after some time you have a full infrastructure running in local, 
ready to start working.
The project currently is at a very early stage, but I am trying to build a good foundation for what is to come.
After all the components are ready, I will include test projects already installed, so you can see examples of how all
components are meant to interact/integrate with each other.
This is not meant to be production ready, but close, so you can deploy it to a home server, and use it for learning purposes.

# Requirements
* Virtual Box (>=6.0.18)
* Vagrant (>=2.2.6)
* Linux/MacOS
* Curl

# Components
## Ready
* Mesos cluster
* Marathon
* Chronos

## Not ready yet
* Mesos DNS
* Gitlab
* Jenkins/Gitlab CI/Circle CI
* Artifactory
* InfluxDB
* Grafana
* ElasticSearch
* Logstash
* Kibana
* PostgreSQL

# Run it yourself
First clone this repo
`git clone git@github.com:zeitgeist2018/infrastructure.git`.

Optionally configure the mesos cluster settings in `cluster-config.json`.

Run it with `./redeploy.sh`. 

After it finishes, you should see your cluster's machines running inside Virtual Box UI.

If you didn't change the cluster's configuration, you should be able to access this hosts:
* Mesos UI: http://192.168.1.100:5050
* Marathon UI: http://192.168.1.100:8080
* Chronos UI: http://192.168.1.100:4400
