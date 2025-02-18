resource "aws_key_pair" "chill_key" {
  key_name = "chill-key"
  public_key = file("../chill-key.pub")
}

