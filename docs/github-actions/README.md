# GitHub Actions

## Purpose

GitHub Actions is the CI side of the platform. It builds and publishes application images.

## Why It Is Needed

- Builds images automatically on push
- Publishes images to GHCR
- Updates deployment manifests or Helm values in Git
- Leaves cluster deployment to Argo CD

## Delivery Model

```text
git push
-> GitHub Actions build
-> GHCR image push
-> Git commit updates manifest or values file
-> Argo CD syncs cluster
```

## Prerequisites

- Application source in GitHub
- A `Dockerfile`
- GHCR enabled for your account or org
- Argo CD already watching the deployment repo

## Install Method

This component is not installed with Helm.

- GitHub Actions lives in GitHub, not in the cluster
- the workflow builds and publishes the image
- Argo CD remains the in-cluster deployment engine

## Installation

Create a workflow file in the application repository at `.github/workflows/build.yml`.

If the package should be private, also plan for image pull credentials in the cluster later.

## Configuration

Decide these details before enabling the workflow:

- image name and tag strategy
- whether the deployment manifests live in the same repo or a separate environment repo
- whether Argo CD tracks plain YAML or Helm values for the app

## Minimal CI Workflow

Create `.github/workflows/build.yml`:

```yaml
name: build-and-push

on:
  push:
    branches: [main]

permissions:
  contents: read
  packages: write

jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/sample-app:${{ github.sha }}
```

## Manifest Update Pattern

After pushing the image, update the Kubernetes manifests or Helm values in Git.

Two common options:

- same repo: update a chart values file in place
- separate environment repo: commit to the deploy repo with a PAT or GitHub App token

Argo CD should deploy from Git, not from a direct `kubectl` step in CI.

## Verification

- confirm the workflow succeeds in GitHub
- confirm a new image exists in `ghcr.io`
- confirm the deployment repo receives the image tag update
- confirm Argo CD syncs the new revision

## Troubleshooting

- If GHCR push fails, check `packages: write` permission.
- If the image is private, make sure the cluster has pull credentials if required.
- If Argo CD does not update, verify the manifest commit actually changed the deployed image tag.

## Notes For This Cluster

- Do not give GitHub Actions direct cluster-admin access unless there is a strong reason.
- Keep CI in GitHub and CD in Argo CD.
- Add image scanning later as part of the security pass.

## Reference

- https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
