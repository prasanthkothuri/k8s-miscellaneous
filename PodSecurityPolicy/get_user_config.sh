# script to retrieve service account config

USERNAME=pkothuri
SERVICE_ACCOUNT=spark
SERVER_NAME=pkothuri

# Retrieve server ip
SERVER=$(awk -F"server: " '{print $2}' ${KUBECONFIG} | sed '/^$/d')

# Retrieve service account secret
SECRET=$(kubectl --kubeconfig="${KUBECONFIG}" \
--namespace "${USERNAME}" \
get serviceaccount "${SERVICE_ACCOUNT}" -o json | python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["secrets"][0]["name"])')

echo "Found secret ${SECRET} for SA ${SERVICE_ACCOUNT} in NS ${USERNAME}."

TOKEN=$(kubectl --kubeconfig="${KUBECONFIG}" \
--namespace "${USERNAME}" \
get secret "${SECRET}" -o json \
| python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["data"]["token"])' | base64 --decode)

CA=$(kubectl --kubeconfig="${KUBECONFIG}" \
--namespace "${USERNAME}" \
get secret "${SECRET}" -o json \
| python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["data"]["ca.crt"])')

cat > k8s-user.config <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $CA
    server: $SERVER
  name: $SERVER_NAME
contexts:
- context:
    cluster: $SERVER_NAME
    namespace: $USERNAME
    user: $SERVICE_ACCOUNT
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: spark
  user:
    token: $TOKEN
EOF
