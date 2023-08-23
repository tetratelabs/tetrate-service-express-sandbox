set -x
export NAMESPACE="sleep"

echo "Enforce A Zero-Trust Security Policy... as per https://docs.tetrate.io/service-express/getting-started/zero-trust"

kubectl create namespace $NAMESPACE 
kubectl label ns $NAMESPACE istio-injection=enabled
kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml

echo "Make sure MTLS is enabled and Deny All policy is enabled..."

cat <<EOF > denyall-organizationsettings.yaml
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
      rules:
        denyAll: true
  displayName: default
EOF

tctl apply -f denyall-organizationsettings.yaml
sleep 10 

RPOD=$(kubectl get pod -n bookinfo -l app=ratings -o jsonpath='{.items[0].metadata.name}')
# Request from bookinfo:ratings to bookinfo:productpage
kubectl exec $RPOD -n bookinfo -c ratings -- curl -s productpage:9080/productpage
# RBAC: access denied
SPOD=$( kubectl get pod -n sleep -l app=sleep -o jsonpath='{.items[0].metadata.name}' )
# Request from sleep:sleep to bookinfo:productpage
kubectl exec $SPOD -n sleep -c sleep -- curl -s productpage.bookinfo:9080/productpage 
# RBAC: access denied

echo "Unlock the Bookinfo workspace..."

cat <<EOF > bookinfo-settings.yaml
apiVersion: api.tsb.tetrate.io/v2
kind: WorkspaceSetting
metadata:
  name: bookinfo-ws-settings
  workspace: bookinfo-ws
  tenant: tse
  organization: tse
spec:
  defaultSecuritySetting:
    authenticationSettings:
      trafficMode: REQUIRED
    authorization:
      mode: WORKSPACE
EOF

tctl apply -f bookinfo-settings.yaml

sleep 30
kubectl exec $RPOD -n bookinfo -c ratings -- curl -s productpage:9080/productpage
kubectl exec $SPOD -n sleep -c sleep -- curl -s productpage.bookinfo:9080/productpage

echo "Enable a flow from sleep to bookinfo..."

cat <<EOF > bookinfo-security.yaml
apiVersion: security.tsb.tetrate.io/v2
kind: Group
metadata:
  name: bookinfo-security
  organization: tse
  tenant: tse
  workspace: bookinfo-ws
spec:
  displayName: Bookinfo Security Group
  namespaceSelector:
    names:
    - '*/*'
  configMode: BRIDGED
---
apiVersion: security.tsb.tetrate.io/v2
kind: ServiceSecuritySetting
metadata:
  name: bookinfo-sss-sleep-productpage
  group: bookinfo-security
  workspace: bookinfo-ws
  tenant: tse
  organization: tse
spec:
  service: bookinfo/productpage.bookinfo.svc.cluster.local
  settings:
    authentication: REQUIRED
    authorization:
      mode: CUSTOM
      serviceAccounts:
      - sleep/*
      - bookinfo/*
EOF

tctl apply -f bookinfo-security.yaml

sleep 30
kubectl exec $SPOD -n sleep -c sleep -- curl -s productpage.bookinfo:9080/productpage | grep "<title>" || true; echo "Deny All policy is in effect..."
