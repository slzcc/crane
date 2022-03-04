helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml --wait true
helm install rancher rancher-latest/rancher   --namespace cattle-system   --set hostname=rancher.example.com