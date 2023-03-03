#!/bin/bash

# error codes
# 2 Invalid base image

declare -A base_images

base_images[slim]=python:slim

DEFAULT_BASE_IMAGE=slim
DEFAULT_TAG=local

tag=$DEFAULT_TAG

while getopts b:t:p: flag
do
    case "${flag}" in
        b) base_image=${OPTARG};;
        t) tag=${OPTARG};;
    esac
done

echo "base_image: $base_image";
echo "tag: $tag";

if [ -z "${base_image}" ]; then
  base_image=$DEFAULT_BASE_IMAGE
fi

expanded_base_image=${base_images[$base_image]}
if [ -z "${expanded_base_image}" ]; then
  echo "invalid base image ["${base_image}"]"
  exit 2
fi

echo "Base Image: ["$expanded_base_image"]"
echo "Tag: ["$tag"]"
echo "Proxy: ["$proxy"]"

docker build . \
    --build-arg BASE_IMAGE=${expanded_base_image} \
    -t giof71/yams:$tag
