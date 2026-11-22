#!/usr/bin/env bash
set -euo pipefail

# Run this after the reviewed release has been merged into main.
release_project_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$release_project_dir"
release_image="waasiqq/readers-haven-final:v2.0"
release_platform="linux/amd64"
release_port="8081"
release_test_container="haven-final-test-$$"
release_final_container="haven-wasiqaliiii-final"
release_active_test=""
release_check_dir="$(mktemp -d)"

cleanup() {
  if [ -n "$release_active_test" ]; then
    docker container stop "$release_active_test" >/dev/null 2>&1 || true
    docker container rm "$release_active_test" >/dev/null 2>&1 || true
  fi
  rm -f "$release_check_dir/repository.json"
  rmdir "$release_check_dir" 2>/dev/null || true
}
trap cleanup EXIT

for release_command in git docker node curl; do
  command -v "$release_command" >/dev/null || {
    printf 'Required command is unavailable: %s\n' "$release_command"
    exit 1
  }
done

if [ -n "$(git status --porcelain)" ]; then
  printf 'Commit or set aside your local changes before running this script.\n'
  exit 1
fi
git fetch origin
git switch main
git pull --ff-only origin main
if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
  printf 'Local main differs from origin/main. Publish only the reviewed remote main commit.\n'
  exit 1
fi

# Check the protected release was incorporated before publishing production.
if ! git merge-base --is-ancestor origin/release/v2.0 HEAD; then
  printf 'Merge the approved release/v2.0 PR into main using a merge commit first.\n'
  exit 1
fi
docker system info >/dev/null
mkdir -p release-evidence

# Require an existing PUBLIC Docker Hub repository before uploading.
if ! curl --fail --silent --show-error \
  https://hub.docker.com/v2/repositories/waasiqq/readers-haven-final/ \
  -o "$release_check_dir/repository.json"; then
  printf 'Create the PUBLIC repository waasiqq/readers-haven-final on Docker Hub, then retry.\n'
  exit 1
fi
node -e 'const fs=require("node:fs");const r=JSON.parse(fs.readFileSync(process.argv[1],"utf8"));if(r.is_private!==false){console.error("The final Docker Hub repository must be public.");process.exit(1)}' \
  "$release_check_dir/repository.json"

docker image build --progress=plain --platform "$release_platform" \
  -t "$release_image" . 2>&1 | tee release-evidence/final-build.log
docker image ls "$release_image" | tee release-evidence/final-image.log
docker image history "$release_image" | tee release-evidence/final-history.log

docker container run -d --platform "$release_platform" \
  --name "$release_test_container" -p "127.0.0.1:$release_port:80" "$release_image"
release_active_test="$release_test_container"
node scripts/check-site.mjs "http://127.0.0.1:$release_port" | tee release-evidence/final-local-test.log
docker container exec "$release_test_container" sh -c 'test ! -d /app/node_modules && ! command -v node'
docker container logs "$release_test_container" >release-evidence/final-container.log 2>&1
docker container stop "$release_test_container"
docker container rm "$release_test_container"
release_active_test=""

# Uses your existing Docker login. If denied, log in with your own PAT and retry.
docker image push "$release_image" 2>&1 | tee release-evidence/final-push.log

# Verify the registry copy without rebuilding.
docker image rm "$release_image"
docker image pull --platform "$release_platform" "$release_image" 2>&1 | tee release-evidence/final-pull.log
docker container run -d --platform "$release_platform" \
  --name "$release_final_container" -p "127.0.0.1:$release_port:80" "$release_image"
node scripts/check-site.mjs "http://127.0.0.1:$release_port" | tee release-evidence/final-pull-test.log
docker container ls | tee release-evidence/final-containers.log
docker image ls "$release_image" | tee release-evidence/final-pulled-image.log
printf '\nFinal image published and pulled successfully: %s\n' "$release_image"
printf 'Open http://localhost:%s and capture your browser and terminal screenshots.\n' "$release_port"
printf 'The final container remains running as %s. Actual command logs are in release-evidence/.\n' "$release_final_container"
