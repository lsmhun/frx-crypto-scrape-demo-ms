# Helm chart frx-crypto-scrape-demo-ms
Demo microservice solution with crypto forex data.

## Data flow
![frx-crypto-scrape-demo-ms](/docs/frx-crypto-diagram.png)

## Pre requisites
You need Kubernetes and [Helm](https://helm.sh) It has been tested with Docker For Windows, because it includes k8s as well.

## Install
Release name is hard coded now (`frx`), because of Helm approach (hard to templating in parent chart's values.yaml). Installation of `frx` deployment:

```console
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm repo add lsmhun https://lsmhun.github.io/lsmhun-helm-charts/
$ helm dep update
$ helm install frx . --create-namespace -n frxns
```
Grafana interface is available through NodePort. 

```console
$ kubectl expose deployment frx --type=NodePort --name=frxgraf -n frxns 
$ kubectl describe service frxgraf -n frxns | grep NodePort:
```
Then you can visit the page: https://127.0.0.1: YOUR_NODE_PORT

Default username and password (admin/admin) is defined in [values.yaml](./values.yaml) .

## Uninstalling the Chart

To uninstall/delete the `frx` deployment:

```console
$ helm delete frx -n frxns
```

The command removes all the Kubernetes components but PVC's associated with the chart and deletes the release.

To delete the PVC's associated with `frx`:

```console
$ kubectl delete pvc -n frxns data-frx-kafka-0 data-frx-postgresql-0  data-frx-zookeeper-0
```

> **Note**: Deleting the PVC's will delete postgresql data as well. Please be cautious before doing it.


## Documentation
- [English documentation](docs/descr_en.md) 
