# Step 08: 변수 파일

environment     = "dev"
container_count = 2

services = {
  web = {
    image = "nginx:alpine"
    port  = 8120
  }
  api = {
    image = "httpd:alpine"
    port  = 8121
  }
}

labels = {
  project     = "terraform-learning"
  environment = "dev"
  managed_by  = "terraform"
  step        = "08-advanced-hcl"
}
