`helm repo add komodorio https://helm-charts.komodor.io`
`helm repo update`
`helm upgrade --install helm-dashboard komodorio/helm-dashboard --set dashboard.allowWriteActions=true  --set dashboard.persistence.enabled=false`

`kubectl apply -f komodor.helm-dashboard/`