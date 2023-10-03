resource "aws_instance" "bation1" {
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.eks_key.key_name
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bation-sg.id]
  tags = {
    Name = "Bastion-eks-dev"
  }
}
resource "null_resource" "copy_ssh_key" {
  depends_on = [aws_instance.bation1]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.eks_key.private_key_pem
    host        = aws_instance.bation1.public_dns
  }

  provisioner "file" {
    source      = "${aws_key_pair.eks_key.key_name}.pem"
    destination = "/home/ec2-user/${aws_key_pair.eks_key.key_name}.pem"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/${aws_key_pair.eks_key.key_name}.pem",
    ]
  }
}