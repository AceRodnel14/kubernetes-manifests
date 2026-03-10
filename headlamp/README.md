`helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/`
`helm install my-headlamp headlamp/headlamp --namespace kube-system`

`kubectl apply -f headlamp/`

`kubectl -n kube-system create serviceaccount headlamp-admin`
`kubectl create clusterrolebinding headlamp-admin --serviceaccount=kube-system:headlamp-admin --clusterrole=cluster-admin`
`kubectl create token headlamp-admin -n kube-system`