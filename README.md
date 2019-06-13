# baseimage-fatjar

![Travis status](https://api.travis-ci.org/Opetushallitus/baseimage-fatjar.svg?branch=master)

A Docker base image for JVM-based services.

## Building on top of this base image

To use this base image for your service, set the `BASE_IMAGE` variable in your `.travis.yml`.

You can either use the latest master build (recommended):

    export BASE_IMAGE="baseimage-fatjar:master"

or the latest build of a specific branch:

    export BASE_IMAGE="baseimage-fatjar:jdk11"

or a specific build:

    export BASE_IMAGE="baseimage-fatjar:ci-9"

After you have set the variable, the `pull-image.sh` script pulls the correct image, and `build-*.sh` script will build your image based on the base image.

## Contributing

Please use branches to avoid producing a broken image with the `master` tag. You can test your branch builds by pulling the specific version for a service.

You can test the build locally on your machine by running:

    docker build -t baseimage-fatjar:latest --build-arg DL_PATH_TOKEN="${DL_PATH_TOKEN}" .

Where `DL_PATH_TOKEN` is the path prefix in the `oph-public-files` bucket, which can be retrieved locally with:

    aws s3 ls s3://oph-public-files --profile oph-utility|sed 's/.*PRE \(.*\)\//\1/g'
