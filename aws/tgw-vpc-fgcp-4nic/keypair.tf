resource "tls_private_key" "pk" {
   algorithm = "ED25519"
 }
resource "aws_key_pair" "awskeypair" {
  key_name   = var.keypair
  public_key = tls_private_key.pk.public_key_openssh
}
resource "local_sensitive_file" "sshprivkey" {
  content  = tls_private_key.pk.private_key_openssh
  filename = "${path.module}/sshkey-${aws_key_pair.awskeypair.key_name}-ssh-priv.pem"
}
resource "local_sensitive_file" "sshpubkey" {
  content  = tls_private_key.pk.public_key_openssh
  filename = "${path.module}/sshkey-${aws_key_pair.awskeypair.key_name}-ssh-pub.pem"
}