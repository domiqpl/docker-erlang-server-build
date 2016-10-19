#!/bin/bash

usage() {
  printf "Usage: /bin/bash -ci '$0 [-s|--save] [-r=<region>|--region=<region>] [-t=<tag>|--tag=<tag>]'\n"
  exit
}

if [ -z $AWS_ACCESS_KEY_ID -o -z $AWS_SECRET_ACCESS_KEY ]; then
  printf "Both WS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables need to be exported prior to running this script\n"
  printf "Try running with 'docker run ... -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY ...'\n"
  usage
fi

if [ ! -d /out ]; then
  printf "/out directory needs to be mapped. Try running with 'docker run ... -v \$(pwd):/out ...'\n"
  usage
fi

for i in "$@"; do
case $i in
  -h|--help)
    usage
    ;;
  -s|--save|-s=true|--save=true)
    SAVE=true
    shift # past argument=value
    ;;
  -t=*|--tag=*)
    TAG="${i#*=}"
    shift # past argument=value
    ;;
  -r=*|--region=*)
    REGION="${i#*=}"
    shift
    ;;
  *)
    shift # unknown option
    ;;
esac
done

REPO=https://git-codecommit.us-east-1.amazonaws.com/v1/repos/erlang-server
SAVE=${SAVE:-false}
TAG=${TAG:-master}
EC2_REGION=${REGION:-eu-west-1}

printf "\nREPO=%s\nSAVE=%s\nTAG=%s\nEC2_REGION=%s\n\n" "$REPO" "$SAVE" "$TAG" "$EC2_REGION"

# clone repository
git clone $REPO server.git
cd server.git

# checkout the requested commit
printf "\nPrepare to build %s\n\n" "$TAG"
git checkout $TAG -q

# in order to use AWS cli helper for git, we need to convert all git.domiq.pl to native amazonws.com url
perl -p -i -e 's|ssh://git.domiq.pl|https://git-codecommit.us-east-1.amazonaws.com|g' rebar.config.lock

# build the project and copy outcome to host (/out should be linked to host directory)
printf "\nBuilding...\n\n"
ENV=prod make generate
cp rel/*.tar.gz /out

# if save was requested, than save to s3
if [ "x$SAVE" == "xtrue" ]; then
  printf "\n\nupload server release to AWS s3...\n"
  for RELEASE in rel/*.tar.gz; do
    aws s3 cp $RELEASE s3://provisioning.domiq/remote/releases/${RELEASE#*/} --region $EC2_REGION
  done
fi
