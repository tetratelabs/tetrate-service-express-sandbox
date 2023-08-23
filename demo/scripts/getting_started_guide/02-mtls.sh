set -x
export NAMESPACE="sleep"

echo "Enforce Encryption with Mutual TLS... as per https://docs.tetrate.io/service-express/getting-started/mtls"

kubectl create namespace $NAMESPACE 
kubectl label ns $NAMESPACE istio-injection=enabled
kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml

echo "Make sure MTLS is enabled and Deny All policy is disabled..."

cat <<EOF > organizationsettings.yaml
apiVersion: api.tsb.tetrate.io/v2
kind: OrganizationSetting
metadata:
  displayName: default
  name: default
  organization: tse
spec:
  defaultSecuritySetting:
    authenticationSettings:
      trafficMode: REQUIRED
    authorization:
      mode: RULES
      rules: {}
  displayName: default
EOF

tctl apply -f organizationsettings.yaml

echo "Validate that the Bookinfo application is accessible..."

# after a couple of seconds, obtain the POD id and store in $POD
POD=$( kubectl get pod -n sleep -l app=sleep -o jsonpath='{.items[0].metadata.name}' )

sleep 10

kubectl exec $POD -n sleep -c sleep -- \
    curl -sS "http://productpage.bookinfo:9080/productpage" | grep "<title>" || true; echo "Deny All policy is in effect..."