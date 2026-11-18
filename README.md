# Readers’ Haven Public Library

A responsive, five-page static website for UCP DevOps Fundamentals Assignment 02, Fall 2026. Plain HTML and one shared CSS file are bundled with Parcel; the shared multi-stage Dockerfile builds with Node.js and serves only the generated website using Nginx.

Repository: https://github.com/wasiqaliiii/readers-haven-library

## Current project stage

This is the project baseline: five linked starter pages, shared styling, the Parcel build, ignore files, and team instructions. The page issues describe work still to be implemented by their contributors. The Dockerfile is proposed separately on `feature/dockerfile` through a PR into `develop`; merge it only after two genuine teammate approvals. Each student must run the required commands on their own machine and capture their own evidence. This repository does not claim those individual tasks are complete.

## Team and page ownership

The user has chosen a three-person team. Keep all five required pages and distribute them as follows:

| Student | GitHub | Responsibility | Feature branches |
| --- | --- | --- | --- |
| Wasiq Ali, Team Lead | `wasiqaliiii` | Home; shared Dockerfile; integration, release, final image and submission | `feature/home-page`, `feature/dockerfile` |
| Hasan Saeed | `hasanSaeed17` | Collections and Membership | `feature/collections-page`, `feature/membership-page` |
| Team Member | `ush11` | Digital Services and Contact | `feature/services-page`, `feature/contact-page` |

Both collaborator invitations were pending when this baseline was prepared. Each student must accept their invitation before pushing or providing an eligible approval. Page issues identify intended owners; GitHub assignment may remain pending until invitations are accepted.

The assignment specifies five students and three approvals for `main`. A three-person group has only two reviewers other than a PR author. This repository uses two required approvals on both `develop` and `main` as a practical adaptation. Confirm the smaller group and this exception with the instructor before submission. The exception has not been represented as instructor-approved.

## Local setup

Install Git, Node.js 22 LTS with npm, and Docker Desktop. On Windows, use the WSL2 backend as required by the assignment. Every student also needs their own Docker Hub account.

```bash
git clone https://github.com/wasiqaliiii/readers-haven-library.git
cd readers-haven-library
git config user.name "your-lowercase-github-username"
git config user.email "your-university-email"
git fetch origin
git switch develop
npm ci
npm run build
npm start
```

Replace the two Git identity placeholders before committing. The development site is available at http://localhost:1234. The build generates all five HTML pages in `dist/`; never commit that folder. If you already cloned the repository under its old name, update its remote:

```bash
git remote set-url origin https://github.com/wasiqaliiii/readers-haven-library.git
```

## Project files

| Path | Purpose |
| --- | --- |
| `src/index.html` | Home page |
| `src/collections.html` | Collections page |
| `src/membership.html` | Membership page |
| `src/services.html` | Digital Services page |
| `src/contact.html` | Contact and static feedback form |
| `styles/style.css` | The only shared stylesheet |
| `package.json`, `package-lock.json` | Parcel scripts and locked dependencies |
| `.gitignore`, `.dockerignore` | Exclude generated files and credentials |
| `Dockerfile` | The only Dockerfile; initially available on `feature/dockerfile` |
| `docs/ASSIGNMENT_GUIDE.md` | Individual Docker commands, evidence checklist and release steps |

## Branch workflow

- `main`: production branch; no direct pushes after baseline setup.
- `develop`: integration branch; feature PRs require two approvals.
- `feature/<page>-page`: one branch per page, created from `develop`.
- `feature/dockerfile`: TL’s shared Dockerfile PR into `develop`.
- `release/v2.0`: create from `develop` only after all pages are implemented and integrated; do not create a final release from this starter project.

The feature branches have been prepared centrally. Each contributor checks out their assigned branch and makes their own descriptive commits:

```bash
git fetch origin
git switch feature/collections-page
git rebase origin/develop
# Edit the assigned page and its section in styles/style.css.
npm ci
npm run build
git add src/collections.html styles/style.css
git commit -m "feat: add library collection categories"
git push -u origin feature/collections-page
```

Before opening or merging a PR, fetch and rebase onto the latest `origin/develop`. If rebasing an already-pushed feature branch rewrites its commits, coordinate with your teammates and use `git push --force-with-lease origin feature/collections-page`. Never force-push `main` or `develop`. Target `develop`, assign Wasiq as TL, and request reviews from the two students other than the PR author. Reviewers must submit their own genuine reviews.

Every HTML page links to `../styles/style.css`. Keep page selectors under `.page-home`, `.page-collections`, `.page-membership`, `.page-services`, or `.page-contact` to reduce shared CSS conflicts. Every page contributor must add a page-specific media query; the baseline's shared media query does not replace this work.

## Docker workflow

Merge the approved Dockerfile PR first, then rebase each feature branch onto `develop`. Run the commands from the repository root, replacing `your-dockerhub-username` and the page name:

```bash
docker image build -t your-dockerhub-username/readers-haven:v1-home .
docker container run -d --name haven-yourusername -p 8081:80 your-dockerhub-username/readers-haven:v1-home
docker container ls
docker container logs haven-yourusername
docker container stop haven-yourusername
docker container rm haven-yourusername
docker login --username your-dockerhub-username
docker image push your-dockerhub-username/readers-haven:v1-home
docker image rm your-dockerhub-username/readers-haven:v1-home
docker image pull your-dockerhub-username/readers-haven:v1-home
```

Enter a Docker Hub access token at the password prompt. Do not place the token in commands, files, screenshots, issues, or Git history. Use public Docker Hub repositories and lowercase names/tags. Use host ports 8081, 8082 and 8083 for serial numbers 1, 2 and 3 respectively. Each member needs at least their own assigned-page image; keep separate image tags if demonstrating both assigned pages.

Use the required management command forms, such as `docker container ls`, `docker image build` and `docker image push`. `docker version` and `docker login` are the explicitly prescribed exceptions. Do not use volumes, custom networks, Compose, a backend, or a JavaScript framework.

The final image is built by the TL from the released `main` and named `<tl-dockerhub-username>/readers-haven-final:v2.0`. A GitHub username does not establish a Docker Hub username: use the TL's actual Docker Hub account. Each student must pull and run that final image without building locally. The TL records the final image in Table 1 and submits the assignment document with both tables, the repository and final Docker Hub URLs, labeled screenshots and a genuine 3–4 line teamwork note.
