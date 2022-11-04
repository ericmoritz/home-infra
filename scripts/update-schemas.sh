#!/usr/bin/env bash
set -ex
version="v1.19.12"
out="schemas/k8s-$version"

rm -rf schemas
mkdir -p "schemas/k8s-$version"
./.venv/bin/openapi2jsonschema -o "$out" --expanded --kubernetes --strict "https://raw.githubusercontent.com/kubernetes/kubernetes/${version}/api/openapi-spec/swagger.json"
