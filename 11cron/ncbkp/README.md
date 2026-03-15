Copy js and json files from scripts folder to where persistent volume is
kubectl apply -f this folder
kubectl create job --from=cronjob/ncbkp-admin manual-test-005