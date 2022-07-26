---
author: Cristian Livadaru
date: "2018-07-20T09:59:17Z"
description: ""
draft: true
slug: gitlab-with-own-kubernetes-cluster
title: Gitlab with own kubernetes cluster
---


```
cat > /tmp/gitlab.yml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: gitlab-managed-apps
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: gitlab-cluster-role
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: gitlab-managed-apps
EOF
```

`kubectl create -f gitlab.yml`

`kubectl create clusterrolebinding ingres-cluster-rule --clusterrole=cluster-admin --serviceaccount=gitlab-managed-apps:ingress-nginx-ingress` 


http://146.255.58.229:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login

