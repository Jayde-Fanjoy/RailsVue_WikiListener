# README
Quick Start:
Pre-req: You need to have docker & docker compsed installed

1. Create an .env file in the directory you want to run the docker that has something like this:
```
SECRET_KEY_BASE="<A secret key, like from rails secret>"
```

2. Run the following command:
 ```
curl -O https://raw.githubusercontent.com/Jayde-Fanjoy/railsvuewikilistener/refs/heads/main/docker-compose.yml && docker compose up
```

3. When the rails app is loaded go to 127.0.0.1:3000

4. Login with the following admin credentials: admin@domain.com and password: password

Welcome, This is more to setup for a simple CI/CD to show how I would set it up. The docker image is a simple rails app that listens to wiki changes and a user who logs into it can get the feed of random users who mades changes to a wiki.

(Fun learning lesson: Always name your docker deployment repos in lower case)

CI:
When a PR is made, Circle CI will run and it will check to see if the tests pass and if the lint succeeds. You should be unable to merge a PR if this is the case.

CD:
Whenever a push is made to the main branch, git action will kick off and then create and deploy the docker image to GitHub Container Registry. 

Deployment:
I've save the image for easy configuration. To log in as an admin and to use the Listener device, use the following email: admin@domain.com and the password: password. As an admin you can start the listener which should recent the recent wikipedia changes and store that information into a Scylla DB.
