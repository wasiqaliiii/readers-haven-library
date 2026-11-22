# Release v2.0 handoff

All five page features have been merged into develop. The release branch incorporates the existing main history while preserving the complete Membership and Collections code from develop.

## Review and merge

1. Check the release validation run. It builds the shared multi-stage Dockerfile, runs Nginx, checks all five pages and their navigation/CSS, and verifies Node.js and node_modules are absent from the runtime.
2. Hasan and ush11 review the release PR into main using their own accounts.
3. After the configured approvals and successful checks, merge the release PR using a merge commit.
4. Merge the release synchronization PR back into develop after the production merge. Do not bypass either branch's review rules.
5. Capture the release PR, actual approvals and merged state for Task 14.

The three-person team uses two required approvals on both protected branches. The handout's group size and three-main-review requirement need an instructor-approved exception documented in the submission.

## Tasks 15 and 16 on the team lead's Mac

Create a PUBLIC Docker Hub repository named readers-haven-final under waasiqq. Your Docker CLI must be logged in to waasiqq using your own access token. Keep the token out of the repository and screenshots.

After the release PR is merged into main, start from a clean local working tree:

~~~bash
git fetch origin
git switch main
git pull --ff-only origin main
bash scripts/publish-final-image.sh
~~~

The script verifies release ancestry and public repository visibility, builds the final image from main, runs and checks all five pages, pushes the image, removes the local copy, pulls it again without rebuilding, and checks the pulled image. It leaves the final container running on localhost:8081 for browser screenshots.

The final image targets linux/amd64 so the team's Intel/AMD Windows machines can run it natively. Docker Desktop on the TL's Apple Silicon Mac runs the same image using emulation. Both the build and local run specify that platform explicitly.

The script only removes the temporary test container it created. If port 8081 or the final container name is already in use, stop your earlier assignment container before retrying. Use the actual logs under release-evidence for evidence; these logs are ignored by Git.

If authentication is needed:

~~~bash
docker login --username waasiqq
~~~

Paste your personal access token at the password prompt. The script does not read, print, or store the token.

## Every teammate's Task 16

Without building locally, each student pulls the TL's final image and runs it on their own port. Example for Hasan, serial 2:

~~~bash
docker image pull --platform linux/amd64 waasiqq/readers-haven-final:v2.0
docker container run -d --platform linux/amd64 --name haven-hasan-final -p 8082:80 waasiqq/readers-haven-final:v2.0
docker container ls
docker container logs haven-hasan-final
~~~

Open localhost:8082 and test all five navigation links. ush11 uses a unique name and port 8083; the TL uses port 8081. Each student captures their own pull, running container and browser screenshots.

## Submission completion

- Table 1: actual student names, GitHub/Docker Hub usernames, roles and branches. The TL records waasiqq/readers-haven-final:v2.0; members record their own Task 12 tags.
- Table 2: actual pushed image tags, image IDs (first 12), sizes, container names and ports from each student's machine. Refresh the TL's values after the final build.
- Paste the public GitHub repository URL and the final Docker Hub repository URL.
- Include real task-numbered screenshots for all required tasks and genuine PR approvals.
- Write 3–4 lines about the team's actual work and challenges.
- Each student's original Docker commands/screenshots must come from their own machine. CI logs support release validation and do not replace individual evidence.
