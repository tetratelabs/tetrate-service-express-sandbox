set -xe
kubectl create namespace bookinfo
kubectl label namespace bookinfo istio-injection=enabled
kubectl apply -f ../../manifests/applications/bookinfo.yaml