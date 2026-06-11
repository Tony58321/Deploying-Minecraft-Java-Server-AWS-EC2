output "instance_public_ip" {
  description = "Public IP address of the Minecraft EC2 instance."
  value       = aws_instance.minecraft_server.public_ip
}

output "minecraft_server_address" {
  description = "Address players can use to connect from Minecraft Java Edition."
  value       = "${aws_instance.minecraft_server.public_ip}:25565"
}

output "nmap_command" {
  description = "Command to verify the Minecraft server port."
  value       = "nmap -sV -Pn -p T:25565 ${aws_instance.minecraft_server.public_ip}"
}

output "ssh_command" {
  description = "SSH command for debugging only. Do not use this in the final demo."
  value       = "ssh -i \"${var.public_key_path}\" ubuntu@${aws_instance.minecraft_server.public_ip}"
}