# variable ingresses {
#     type = list({from_port = number, to_port = number, protocol = number, cidr_blocks=list(string)})
#     default = [ {

#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["172.31.0.0/16"]
  
#     }, 
    
#      {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["172.31.0.0/16"]
#   }

#     ]
# }