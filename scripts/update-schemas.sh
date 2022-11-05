#!/usr/bin/env bash
set -ex
version="v1.25.3"
out="schemas/k8s"

rm -rf schemas
mkdir -p "$out"
./.venv/bin/openapi2jsonschema -o "$out" --expanded --kubernetes --strict "https://raw.githubusercontent.com/kubernetes/kubernetes/${version}/api/openapi-spec/swagger.json"
