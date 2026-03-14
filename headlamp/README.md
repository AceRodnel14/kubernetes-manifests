`kubectl apply -f headlamp/`</br>
</br>
`helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/`</br>
`helm upgrade --install headlamp headlamp/headlamp -f headlamp/values.yml --namespace kube-system`</br>


`kubectl -n kube-system create serviceaccount headlamp-admin`</br>
`kubectl create clusterrolebinding headlamp-admin --serviceaccount=kube-system:headlamp-admin --clusterrole=cluster-admin`</br>
`kubectl create token headlamp-admin -n kube-system`</br>