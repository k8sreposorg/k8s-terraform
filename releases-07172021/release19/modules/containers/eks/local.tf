locals{
userdata = <<USERDATA
#!/bin/bash
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.this.endpoint}'   --b64-cluster-ca '${aws_eks_cluster.this.certificate_authority[0].data}'     '${aws_eks_cluster.this.name}'

USERDATA
}

