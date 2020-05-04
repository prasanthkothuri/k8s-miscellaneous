#### Create k8s cluster (with PodSecurityPolicy [enabled](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#enabling-pod-security-policies) in admission controller)

##### without PodSecurityPolicy

```
# create namespace, serviceaccount, role and rolebinding
kubectl apply -f no_psp.yaml
# run pod as service account pkothuri::spark
kubectl --as=system:serviceaccount:pkothuri:spark -n pkothuri apply -f pod.yaml
```
you will see the below error
```
Error from server (Forbidden): error when creating "pod.yaml": pods "pause" is forbidden: unable to validate against any pod security policy: []
```

##### with PodSecurityPolicy

```
# cleanup
kubectl delete -f no_psp.yaml
# create podsecuritypolicy, namespace, serviceaccount, role and rolebinding
kubectl apply -f psp.yaml
# run pod as service account pkothuri::spark
kubectl --as=system:serviceaccount:pkothuri:spark -n pkothuri apply -f pod.yaml
```
now you should be able to run the pod as you have created PodSecurityPolicy and assigned to the service account with RBAC
in addition if you try to mount a volume that is not allowed
```
kubectl --as=system:serviceaccount:pkothuri:spark -n pkothuri apply -f podv.yaml
```
you will see the below error
```
Error from server (Forbidden): error when creating "podv.yaml": pods "mypod" is forbidden: unable to validate against any pod security policy: [spec.volumes[0].hostPath.pathPrefix: Invalid value: "/tmp": is not allowed to be used]
```
