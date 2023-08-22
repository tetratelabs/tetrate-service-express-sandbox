set -x
export NAMESPACE="sleep"

kubectl create namespace $NAMESPACE 
kubectl label ns $NAMESPACE istio-injection=enabled
kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml

# after a couple of seconds, obtain the POD id and store in $POD
POD=$( kubectl get pod -n sleep -l app=sleep -o jsonpath='{.items[0].metadata.name}' )

sleep 10

kubectl exec $POD -n sleep -c sleep -- \
    curl -sS "http://productpage.bookinfo:9080/productpage" | grep "<title>"