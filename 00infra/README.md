1. Deploy metallb
   `kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml`
2. Configure metallb
   - Deploy metallb.yml
3. Deploy traefik
   - Deploy traefik-rbac.yml
   - Deploy traefik.yml
   - kubectl rollout restart deploy traefik -n traefik
4. 