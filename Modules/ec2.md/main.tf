data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "my_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
   key_name                = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = var.instance_name
  }

  user_data = var.user_data

  lifecycle {
    ignore_changes = [ami]
  }
}

# resource "null_resource" "remote_exec_enabled" {
#   provisioner "remote-exec" {
#     inline = var.remote_exec
#   }

#   connection {
#     type        = "ssh"
#     host        = aws_instance.my_instance.public_ip
#     user        = "ec2-user"
#      private_key = file(var.private_key)
#   }
#    depends_on = [aws_instance.my_instance]
# }


resource "aws_lb_target_group_attachment" "ec2_target" {

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.my_instance.id
  port             = 80
}
