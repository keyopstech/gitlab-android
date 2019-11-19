# gitlab-android
Builds an image for building Android app with gitlab CI

# Deployoing image

A new version of the image is deployed to docker hub everytime a commit is added to a branch.

A commit to master will build a new version of the `latest` tag.

For all other branches, it will deploy an image tagged with the branch name. eg. pushing to `foobar` branch will trigger a new image tag `foobar` in docker hub

# Update Ruby

Ruby version is managed by rvm.

In order to get the latest version of Ruby, just rebuild the Docker image `docker build . -t <local tag you want>`

Run it with an interactive shell `docker run -ti <local tag> bash`

Run `source /usr/local/rvm/scripts/rvm` in the container. It will allow you to use `rvm` in a simple way.

Run `rvm list`. You will see the current version of ruby.

If this is not the version set in the path by the Dockerfile (Check the `ENV PATH "<path>:${PATH}"`) line, replace it in the Dockerfile.

Rebuild the image.

Push it.
