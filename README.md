# README

Welcome, This is more to setup for a simple CI/CD to show how I would set it up. The docker image is a simple rails app that listens to wiki changes and a user who logs into it can get the feed of random users who mades changes to a wiki.

CI:
When a PR is made, Circle CI will run and it will check to see if the tests pass and if the lint succeeds. You should be unable to merge a PR if this is the case.

CD:
Whenever a push is made to the main branch, git action will kick off and then create and deploy the docker image to GitHub Container Registry. 

Deployment:
I've save the image for easy configuration. To log in as an admin and to use the Listener device, use the following email: admin@domain.com and the password: password. As an admin you can start the listener which should recent the recent wikipedia changes and store that information into a Scylla DB.
