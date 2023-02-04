Please check this blog [post](https://dev.to/networkandcode/harperdb-helm-chart-on-artifact-hub-3066) for details on how to deploy this helm 
chart.

To install from the chart:
```
git clone git@github.com:networkandcode/harperdb-deployments.git

cd harperdb-deployments/helm-charts/standard

helm install harperdb harperdb -n harperdb
```

To install from the artifact hub:
```
$ helm repo add networkandcode https://networkandcode.github.io/helm-packages

$ helm install harperdb networkandcode/harperdb --version 0.1.0 -n harperdb
```

