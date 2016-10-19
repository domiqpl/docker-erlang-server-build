# erlang-server-build

Docker image definition for erlang-server-build
This image will build erlang-server-build for a given tag and save to AWS S3.

### Prerequisites

Before being able to use the script, you need to obtain your AWS key id and secret key.

Please consult AWS documentation to:
  * [generate access keys](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)
  * [attach policies](http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage.html)

Your AWS AIM user needs the following policies attached to be able to prepare the build:
  * AWSCodeCommitReadOnly

The following policies are needed if you want to publish the generated release:
  * S3ProvisioningAccess

Before executing the build process inside docker image, you will need to export you keys and forward them into your docker container:

```shell
export AWS_ACCESS_KEY_ID=<your key id>
export AWS_SECRET_ACCESS_KEY=<your access key>
```

### Usage

The domiq/erlang-server-build docker image has a ./build.xml which will build erlang-server image.

To see available options you can run the docker image with no arguments:

```shell
$ docker run -it --rm -v $(pwd):/out -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY domiq/erlang-server-build

Usage: /bin/bash -ci './build.sh [-s|--save] [-r=<region>|--region=<region>] [-t=<tag>|--tag=<tag>]'
```

build.sh arguments:
  * -s|--save   - save the generated erlang server image to AWS S3
  * -r|--region - specify the region of S3 bucket (defaults to eu-west-1)
  * -t|--tag    - specify commid_id or TAG in the repository that you want to build
  * -h|--help   - display usage



```shell
$ docker run -it --rm -v $(pwd):/out -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY domiq/erlang-server-build /bin/bash -ci "./build.sh -t=master -s"
```

