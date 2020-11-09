#!/usr/bin/env bash

# Install a basic web server to handle HTTP health checks
sudo apt-get install -y nginx

cat > kubernetes.default.svc.cluster.local << EOF
server {
    listen      80;
    server_name kubernetes.default.svc.cluster.local;

    location /healthz {
        proxy_pass                    https://127.0.0.1:6443/healthz;
        proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
    }
}
EOF

{
  sudo mv kubernetes.default.svc.cluster.local \
    /etc/nginx/sites-available/kubernetes.default.svc.cluster.local

  sudo ln -s /etc/nginx/sites-available/kubernetes.default.svc.cluster.local /etc/nginx/sites-enabled/
}

sudo systemctl restart nginx

sudo systemctl enable nginx

# Verification
kubectl get componentstatuses --kubeconfig admin.kubeconfig

# Test the nginx HTTP health check proxy
curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz
