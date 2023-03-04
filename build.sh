#!/bin/bash

# error codes
# 2 Invalid base image

declare -A base_images

base_images[slim]=python:slim

DEFAULT_BASE_IMAGE=slim
DEFAULT_TAG=local
DEFAULT_USE_PROXY=N

tag=$DEFAULT_TAG
use_proxy=$DEFAULT_USE_PROXY

while getopts b:t:p: flag
do
    case "${flag}" in
        b) base_image=${OPTARG};;
        t) tag=${OPTARG};;
        p) proxy=${OPTARG};;
    esac
done

echo "base_image: $base_image";
echo "tag: $tag";
echo "proxy: $proxy";

if [ -z "${base_image}" ]; then
  base_image=$DEFAULT_BASE_IMAGE
fi

if [ -z "${proxy}" ]; then
  use_proxy="N"
else
  use_proxy=$proxy
fi

expanded_base_image=${base_images[$base_image]}
if [ -z "${expanded_base_image}" ]; then
  echo "invalid base image ["${base_image}"]"
  exit 2
fi

echo "Base Image: ["$expanded_base_image"]"
echo "Tag: ["$tag"]"
echo "Proxy: ["$use_proxy"]"

docker build . \
    --build-arg BASE_IMAGE=${expanded_base_image} \
    --build-arg USE_APT_PROXY=${use_proxy} \
    -t giof71/yams:$tag
