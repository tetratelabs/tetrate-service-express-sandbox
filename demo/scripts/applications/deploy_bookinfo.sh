set -x
kubectl create namespace bookinfo
kubectl label namespace bookinfo istio-injection=enabled
kubectl apply -f demo/manifests/applications/bookinfo.yaml
