# Trimaran KubeCon 2021 & 2024 EU demo
The repo is adapted from samples in 2021 trimaran demo. In KubeCon 2024 EU, we add the 3rd scheduler plugin demo accordingly.

## Prerequisites
1. Build the trimaran plugin images from the latest [scheduler-plugin](https://github.com/kubernetes-sigs/scheduler-plugins.git) repo.
```bash
cd $GOPATH/src/sigs.k8s.io/
git clone https://github.com/kubernetes-sigs/scheduler-plugins.git
cd scheduler-plugins
```

2. Configure your own image repo and build the image.
```bash
export REGISTRY=quay.io/chenw615
export BUILDER=podman
make local-image
```

3. Push the images to your own repo for testing.
```
docker push quay.io/chenw615/kube-scheduler:latest
docker push quay.io/chenw615/controller:latest
```

## TargetLoadPacking Demo
1. Make sure you create the namespaces to run the Trimaran scheduler and also the testing pods.
```
kubectl create ns trimaran
kubectl label namespaces trimaran name=trimaran    # Label the namespace with trimaran so the networkpolicy can configure it accessing prometheus
kubectl create ns trimaran-test
```

2. Define networkpolicy for trimaran namespace and scheduler deployment to access Prometheus
```
kubectl create -f trimaran-networkpolicy.yaml
```

3. Deploy the scheduler that only enables the TargetLoadPacking plugin.
```
kubectl create -f targetloadpacking.yaml
```



