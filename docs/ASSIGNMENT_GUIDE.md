# Assignment commands and evidence

Run these on your own computer and capture genuine outputs. These are instructions, not evidence of completed Docker tasks. The page implementations, reviewer approvals, Docker Hub publications and final release remain team work after repository setup.

## Student identifiers

| Table serial | GitHub | Host port | Assigned pages |
| --- | --- | --- | --- |
| 1 | `wasiqaliiii` | 8081 | Home |
| 2 | `hasanSaeed17` | 8082 | Collections and Membership |
| 3 | `ush11` | 8083 | Services and Contact |

The following examples use serial 1. Other students replace the username, image tag and host port. Use your actual lowercase Docker Hub username, which may differ from GitHub.

## Tasks 4 to 6 — Docker basics

```bash
docker version
docker system info
docker container run hello-world
docker image pull nginx:1.27-alpine
docker container run -d --name haven-yourusername-nginx -p 8081:80 nginx:1.27-alpine
docker container ls
docker container logs haven-yourusername-nginx
docker container exec -it haven-yourusername-nginx sh
```

Inside the container shell, run:

```sh
ls /usr/share/nginx/html
exit
```

Open http://localhost:8081 to capture the Nginx browser view. Then demonstrate the lifecycle:

```bash
docker container stop haven-yourusername-nginx
docker container ls -a
docker container start haven-yourusername-nginx
docker container ls
# Stop again before removal; removing a running container fails.
docker container stop haven-yourusername-nginx
docker container rm haven-yourusername-nginx
docker image ls
docker image history nginx:1.27-alpine
docker image inspect nginx:1.27-alpine
docker image inspect --format '{{len .RootFS.Layers}}' nginx:1.27-alpine
```

Hello-world explanation: Docker pulls the image if it is missing locally, creates and runs a container, prints the message, and the container exits.

Use the actual count from `.RootFS.Layers`, which can vary with platform and image revision. A filesystem layer records a reusable set of changes in an image; metadata-only history entries do not add filesystem layers.

## Tasks 9 to 12 — Build and publish your page image

After the Dockerfile PR is approved and merged:

```bash
git fetch origin
git switch feature/home-page
git rebase origin/develop
npm ci
npm run build
docker image build -t your-dockerhub-username/readers-haven:v1-home .
# Repeat without editing anything to inspect cached layers.
docker image build -t your-dockerhub-username/readers-haven:v1-home .
docker image ls
docker image history your-dockerhub-username/readers-haven:v1-home
docker image inspect your-dockerhub-username/readers-haven:v1-home
docker container run -d --name haven-yourusername -p 8081:80 your-dockerhub-username/readers-haven:v1-home
docker container ls
docker container logs haven-yourusername
```

Open http://localhost:8081 and check every navigation link. Record the image ID (first 12 characters), size, container name and host port in Table 2 from actual output. Then clean up and verify Docker Hub:

```bash
docker container stop haven-yourusername
docker container rm haven-yourusername
docker login --username your-dockerhub-username
docker image push your-dockerhub-username/readers-haven:v1-home
docker image rm your-dockerhub-username/readers-haven:v1-home
docker image pull your-dockerhub-username/readers-haven:v1-home
docker image ls
```

Enter an access token only at the login password prompt. Keep the Docker Hub repository public and screenshot its public visibility and image tag. A successful push followed by a fresh pull verifies publication.

## Tasks 14 to 16 — Release only after all pages are complete

The TL first checks that all five page PRs are merged and tested on `develop`:

```bash
git fetch origin
git switch develop
git pull --ff-only origin develop
git switch -c release/v2.0
npm ci
npm run build
docker image build -t your-dockerhub-username/readers-haven-final:v2.0-rc1 .
docker container run -d --name haven-release-test -p 8081:80 your-dockerhub-username/readers-haven-final:v2.0-rc1
docker container ls
docker container logs haven-release-test
```

Check all five pages and responsive layouts before continuing:

```bash
docker container stop haven-release-test
docker container rm haven-release-test
git push -u origin release/v2.0
```

Open a PR from `release/v2.0` to `main` and obtain the required genuine reviews. With this three-person group, two approvals are configured; instructor agreement is still needed for the deviation from three approvals in the assignment. After the release is accepted, open a synchronization PR from `release/v2.0` to `develop` if there are release changes to bring back. If GitHub reports no changes, verify the release is already incorporated rather than creating empty commits for evidence.

From the released `main`, the TL builds, tests and publishes:

```bash
git switch main
git pull --ff-only origin main
docker image build -t your-dockerhub-username/readers-haven-final:v2.0 .
docker container run -d --name haven-final-test -p 8081:80 your-dockerhub-username/readers-haven-final:v2.0
docker container ls
docker container logs haven-final-test
```

After the browser test:

```bash
docker container stop haven-final-test
docker container rm haven-final-test
docker image push your-dockerhub-username/readers-haven-final:v2.0
```

For Task 16, every student uses the TL's actual Docker Hub username and their own host port. The TL first removes their local final image so their own test also demonstrates a registry pull:

```bash
docker image rm your-dockerhub-username/readers-haven-final:v2.0
docker image pull your-dockerhub-username/readers-haven-final:v2.0
docker container run -d --name haven-final-yourusername -p 8081:80 your-dockerhub-username/readers-haven-final:v2.0
docker container ls
```

Do not build locally for Task 16. Open all pages and verify navigation. Keep platform compatibility in mind: an image built only for ARM64 may not run natively on a teammate's x86-64 machine. If the team uses mixed architectures, agree a compatible target platform or use Docker's supported multi-platform build workflow; capture the actual commands used.

## Screenshot checklist

| Task | Evidence to capture |
| --- | --- |
| 1 | Baseline files, Parcel dependency and build script, public repository |
| 2 | Accepted collaborators; protection rules for `main` and `develop` |
| 3 | Five page issues with owners; feature branches |
| 4 | Docker version, system information and hello-world output |
| 5 | Nginx running container, logs, browser view and shell file listing |
| 6 | Stop/start/remove lifecycle; image list, history, inspect and actual layer count |
| 7 | Commented two-stage Dockerfile, `.dockerignore`, and approved PR into `develop` |
| 8 | Own descriptive commits, assigned page and page-specific CSS media query |
| 9 | Successful Parcel build and all five generated HTML files in `dist/` |
| 10 | Both build stages, repeat build with cached layers, image list, history and size |
| 11 | Custom container list, browser view and logs |
| 12 | Successful image push, public Docker Hub repository, local removal and fresh pull |
| 13 | Rebase/conflict resolution as applicable; page PRs with two approvals |
| 14 | Tested release branch, release PR to `main` and synchronization with `develop` |
| 15 | TL final image build, local test and push from released `main` |
| 16 | Each student's final-image pull, running container and working five-page navigation |

The TL submits the supplied assignment document with Tables 1 and 2, the GitHub URL, the final Docker Hub URL, task-labeled screenshots and a 3–4 line account of the team's real work and challenges. Record the final image for the TL in Table 1; record members' actual Task 12 images for their rows. Do not invent IDs, sizes, reviews or successful runs. Record any instructor-approved change to the group size and review counts explicitly.
