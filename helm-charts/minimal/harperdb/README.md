Please check this blog [post](https://dev.to/aws-builders/harperdb-with-helm-on-eks-3fb9) for details on how to deploy this helm chart.

To install from the chart:
```
git clone git@github.com:networkandcode/harperdb-deployments.git

cd harperdb-deployments/helm-charts/minimal

helm install harperdb harperdb -n harperdb
```

