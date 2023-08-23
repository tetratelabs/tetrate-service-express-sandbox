set -x
export NAMESPACE="bookinfo"

echo "Deploying application... as per https://docs.tetrate.io/service-express/getting-started/deploy-application"

kubectl create namespace $NAMESPACE
kubectl label namespace $NAMESPACE istio-injection=enabled
kubectl apply -f demo/manifests/getting_started_guide/bookinfo.yaml -n $NAMESPACE

cat <<EOF > $NAMESPACE-ws.yaml
apiversion: api.tsb.tetrate.io/v2
kind: Workspace
metadata:
  organization: tse
  tenant: tse
  name: $NAMESPACE-ws
spec:
  namespaceSelector:
    names:
      - "*/$NAMESPACE"
EOF

tctl apply -f $NAMESPACE-ws.yaml

sleep 60

kubectl exec "$(kubectl get pod -n $NAMESPACE -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -n $NAMESPACE -c ratings -- curl -s productpage:9080/productpage | grep "<title>" || true; echo "Deny All policy is in effect..."