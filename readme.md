# Building Microservices with Node, Docker, MongoDBAtlas and Nginx

This simple web application aims to demonstrate the communication between microservices.

In the local version of the deployment of the web app there are 5 microservices: web, search, books, videos and web-server.

The web-server consists of an nginx server that serves the web container. This nginx server acts as an API Gateway,
forwarding the all request to the correct microservice. For instance:
    
If you enter any text in the "Videos" input and click the "create" button, the request will be redirected to :3003.

There are 2 ways to provision the web app locally:
    
    1. docker compose up;
    2. terraform init, apply (in order to to this, replace the outer main.tf with the modules/local/provision-locally.tf)

After the provisioning, the frontend url should be "localhost:8080"

## Remote Version
In the remote version of the deployment, there are 4 microservices being deployed to GCP: web, search, books and videos.

I was not able to make an nginx container and edit its configuration to receive dynamic ip addresses from the other microservices containers.

With this being said, after many tries (that will be described in the report) i tried to recreate the whole app in Vue.

Which i wasnt able to finish in time.

So, the services are uploaded to the GCP Cloud but they can communicate with each other.


Frontend url for remote web app should be: https://web-x7msqww2zq-uc.a.run.app

Search microservice: https://search-x7msqww2zq-uc.a.run.app
Books microservice: https://books-x7msqww2zq-uc.a.run.app
Videos microservice: https://videos-x7msqww2zq-uc.a.run.app