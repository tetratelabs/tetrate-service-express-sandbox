set -x

echo "Publishing a Service... as per https://docs.tetrate.io/service-express/getting-started/publish-service"

echo "Deploy an Ingress Gateway..."

cat <<EOF > ingress-gw-install.yaml
apiVersion: install.tetrate.io/v1alpha1
kind: IngressGateway
metadata:
  name: bookinfo-ingress-gw
  namespace: bookinfo
spec:
  kubeSpec:
    service:
      type: LoadBalancer
EOF

kubectl apply -f ingress-gw-install.yaml
sleep 10

echo "Expose the Bookinfo productpage service..."

cat <<EOF > bookinfo-group-ingress.yaml
apiVersion: gateway.tsb.tetrate.io/v2
kind: Group
metadata:
  displayName: bookinfo
  name: bookinfo-gwgroup
  organization: tse
  tenant: tse
  workspace: bookinfo-ws
spec:
  displayName: bookinfo
  namespaceSelector:
    names:
      - "*/bookinfo"
---
apiVersion: gateway.tsb.tetrate.io/v2
kind: IngressGateway
metadata:
  organization: tse
  tenant: tse
  group: bookinfo-gwgroup
  workspace: bookinfo-ws
  name: bookinfo-gw
spec:
  workloadSelector:
    namespace: bookinfo
    labels:
      app: bookinfo-ingress-gw
  http:
  - name: bookinfo
    port: 80
    hostname: bookinfo.$cluster_name.aws-ce.sandbox.tetrate.io
    routing:
      rules:
      - route:
          host: bookinfo/productpage.bookinfo.svc.cluster.local
          port: 9080
EOF

tctl apply -f bookinfo-group-ingress.yaml
sleep 10

echo "Accessing the Service..."

export GATEWAY_IP=$(kubectl -n bookinfo get service bookinfo-ingress-gw -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")

curl -s --connect-to bookinfo.tse.tetratelabs.io:80:$GATEWAY_IP \
    "http://bookinfo.tse.tetratelabs.io/productpage" | \
    grep "<title>" || true; echo "Deny All policy is in effect..."