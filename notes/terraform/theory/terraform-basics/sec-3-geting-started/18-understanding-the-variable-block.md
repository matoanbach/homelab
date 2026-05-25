# Regular variables
- variables.tf
```tf
variable "filename" {
    default = "/root/pets.txt"
    type = string
    description = "the path of local file"
} 

variable "content" {
    default = "I love pets!"
    type = string
    description = "the content of the file"
}

variable "prefix" {
    default = "Mrs"
    type = string
    description = "The prefix to be set"
}
```

# List
- variables.tf
```tf
variable "prefix" {
    default = ["Mr", "Mrs", "Sir"]
    type = list(string)
}
```

# Map
- variables.tf
```tf
variable file-content {
    type = map
    default = {
        "statement1" = "We love pets!"
        "statement2" = "We love animals"
    }
}
```

# Set
- variables.tf
```tf
variable "prefix" {
    default = ["Mr", "Mrs"]
    type = set(string)
}
```

# Objects
- variables.tf
```tf
variable "bella" {
    type = object({
        name = string
        color = string
        age = number
        food = list(string)
        favorite_pet = bool
    })

    default = {
        name = "bella"
        color = "brown"
        age = 7
        food = ["fish", "chicken", "turkey"]
        favorite_pet = true
    }
}
```

# Tuples
- variables.tf
```tf
variable kitty {
    type = tuple([string, number, bool])
    default = ["cat", 7, true]
}
```

# Other ways to define
- We can use `terraform.tfvars`

# Variable Definition Precedence
1. `export TF_VAR_filename="/root/cats.txt"`
2. terraform.tfvars - `filename="/root/pets.txt"`
3. variable.auto.tfvars - `filename="/root/mypet.txt"`
4. `terraform apply -var "filename=/root/best-pet.txt"`