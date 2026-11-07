# CloudDock

## Secure Containerized Cloud Deployment Platform

CloudDock is a security-focused container deployment project that demonstrates how a Flask application can be containerized, hardened, scanned for vulnerabilities, and integrated into an automated CI/CD security workflow.

The project focuses on improving container security before deployment through Docker hardening practices, Trivy vulnerability scanning, and GitHub Actions automation.

---

## 1. Project Overview

CloudDock demonstrates a secure container development and deployment workflow.

The project uses a Flask application as the application workload and Docker to package it into a container image.

The security workflow includes:

1. Building a baseline Docker image.
2. Scanning the baseline image using Trivy.
3. Applying Docker image hardening techniques.
4. Building a hardened Docker image.
5. Scanning the hardened image.
6. Comparing vulnerability findings.
7. Automating image building and security checks using GitHub Actions.
8. Publishing validated images to GitHub Container Registry (GHCR).

The project also demonstrates secure local container deployment using Docker Compose.

---

## 2. Objectives

The primary objectives of CloudDock are:

- Containerize a Flask web application using Docker.
- Establish a baseline for container vulnerability assessment.
- Reduce unnecessary packages and dependencies in the runtime image.
- Implement multi-stage Docker builds.
- Run containers using a non-root user.
- Apply container runtime security restrictions.
- Scan container images using Trivy.
- Compare baseline and hardened image vulnerabilities.
- Integrate vulnerability scanning into GitHub Actions.
- Enforce a security gate for CRITICAL vulnerabilities.
- Publish validated container images to GHCR.
- Provide CI/CD status notifications through Slack webhooks.

---

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Python | Application development |
| Flask | Web application framework |
| Docker | Containerization |
| Docker Compose | Local container deployment |
| Trivy | Container vulnerability scanning |
| Git and GitHub | Version control and source-code management |
| GitHub Actions | CI/CD automation |
| GitHub Container Registry | Container image publishing |
| Slack Webhooks | Pipeline notifications |
| Ubuntu | Development environment |

---

## 4. Project Status

### Completed

- Flask application with home and health-check endpoints.
- Baseline Docker image creation.
- Baseline vulnerability scanning using Trivy.
- Multi-stage Docker build.
- Python dependency updates.
- Reduced runtime package footprint.
- Non-root container execution.
- Hardened Docker image creation.
- Hardened image vulnerability scanning.
- Docker Compose deployment.
- Read-only container filesystem.
- Dropped Linux capabilities.
- No-new-privileges security configuration.
- Container health checks.
- GitHub Actions workflow for automated image building and scanning.
- CRITICAL vulnerability security gate.
- GHCR image publishing workflow.
- Slack notification steps in the CI/CD workflow.

### Remaining / Future Work

- Configure and verify actual Slack webhook delivery using GitHub Secrets.
- Synchronize repository Trivy reports with the latest scan results.
- Implement AWS deployment.
- Add production-grade deployment monitoring and rollback mechanisms.

---

## 5. Project Structure

```text
CloudDock/
│
├── app/
│   └── app.py
│
├── .github/
│   └── workflows/
│       └── security-scan.yml
│
├── Dockerfile
├── compose.yaml
├── requirements.txt
├── .dockerignore
├── .gitignore
│
├── trivy-baseline.json
├── trivy-baseline.txt
├── trivy-hardened.json
│
└── README.md
```

---

## 6. Docker Architecture

CloudDock uses a multi-stage Docker build to separate dependency installation from the final runtime environment.

### Stage 1 - Builder

The builder stage:

- Uses the Python 3.11 slim base image.
- Creates a Python virtual environment.
- Installs the required application dependencies.
- Updates Python packaging tools.
- Prepares the virtual environment for the runtime stage.

### Stage 2 - Runtime

The runtime stage:

- Uses a Python 3.11 slim base image.
- Updates operating-system packages.
- Installs updated Python packaging tools.
- Creates a dedicated non-root user named `appuser`.
- Copies the prepared virtual environment from the builder stage.
- Copies the Flask application.
- Runs the application using the non-root user.

This approach separates the build environment from the runtime environment and reduces unnecessary components in the final image.

---

## 7. Security Hardening

CloudDock applies multiple container hardening techniques.

### Non-root execution

The application runs using a dedicated non-root user named `appuser` instead of the root account.

This follows the principle of least privilege.

### Multi-stage build

A multi-stage Docker build separates dependency preparation from the final runtime image.

Only the prepared application environment is copied into the runtime stage.

### Slim runtime image

The project uses the Python slim image to reduce the runtime footprint.

Unnecessary packages and components are avoided wherever possible.

### Python dependency updates

Python packaging tools are updated to secure versions during image construction.

### Docker ignore rules

The `.dockerignore` file prevents unnecessary development files and local artifacts from being copied into the Docker build context.

### Runtime security using Docker Compose

The hardened container uses the following runtime restrictions:

- Non-root execution.
- Read-only root filesystem.
- All Linux capabilities dropped.
- No-new-privileges security option.
- Temporary writable storage through a restricted `/tmp` tmpfs.
- Container health checks.

These configurations reduce the container's privileges and writable attack surface.

---

## 8. Running the Application

### Run directly with Python

Navigate to the project directory:

```bash
cd CloudDock
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Start the application:

```bash
python app/app.py
```

Open the application:

```text
http://localhost:5000
```

Health-check endpoint:

```text
http://localhost:5000/health
```

### Run using Docker

Build the hardened image:

```bash
docker build -t clouddock-app:hardened .
```

Run the container:

```bash
docker run -d \
  --name clouddock-test \
  -p 5000:5000 \
  clouddock-app:hardened
```

Check the running container:

```bash
docker ps
```

Check application logs:

```bash
docker logs clouddock-test
```

Test the application:

```bash
curl http://localhost:5000/
```

Test the health endpoint:

```bash
curl http://localhost:5000/health
```

### Recommended: Hardened Runtime Deployment Using Docker Compose

Build the hardened image:

```bash
docker build -t clouddock-app:hardened .
```

Start the application:

```bash
docker compose up -d
```

Check container status:

```bash
docker compose ps
```

View application logs:

```bash
docker compose logs
```

Test the endpoints:

```bash
curl http://localhost:5000/
```

```bash
curl http://localhost:5000/health
```

Stop the deployment:

```bash
docker compose down
```

The Compose deployment was tested successfully. Both application endpoints returned HTTP 200, and the container reported a healthy status.

The runtime security configuration was independently verified using Docker inspection and in-container security tests.

---

## 9. Trivy Security Scanning

Trivy is used to identify known vulnerabilities in container images.

Both baseline and hardened images were scanned using Trivy 0.74.0 with identical vulnerability-scanning settings and HIGH/CRITICAL severity filters.

### Baseline scan

```bash
trivy image \
  --scanners vuln \
  --severity HIGH,CRITICAL \
  --timeout 20m \
  --format json \
  --output /tmp/clouddock-baseline-final.json \
  clouddock-app:baseline
```

### Hardened scan

```bash
trivy image \
  --scanners vuln \
  --severity HIGH,CRITICAL \
  --timeout 20m \
  --format json \
  --output /tmp/clouddock-hardened-final.json \
  clouddock-app:hardened
```

### Critical vulnerabilities only

```bash
trivy image \
  --scanners vuln \
  --severity CRITICAL \
  --timeout 20m \
  clouddock-app:hardened
```

---

## 10. Security Results

The following results were obtained on 7 November 2026 using Trivy 0.74.0. Both images were scanned with identical settings and HIGH/CRITICAL severity filters.

### Baseline image

- Image: `clouddock-app:baseline`
- Operating system: Debian 13.6
- Detected packages: 469

| Severity | Findings |
|---|---:|
| HIGH | 1,015 |
| CRITICAL | 61 |
| **HIGH + CRITICAL** | **1,076** |
| Unique CVEs | 401 |

### Hardened image

- Image: `clouddock-app:hardened`
- Operating system: Debian 13.7
- Detected packages: 87

| Severity | Findings |
|---|---:|
| HIGH | 49 |
| CRITICAL | 0 |
| **HIGH + CRITICAL** | **49** |
| Unique CVEs | 13 |

### Improvement after hardening

| Metric | Improvement |
|---|---:|
| HIGH findings | 95.17% reduction |
| CRITICAL findings | 100% reduction |
| Total HIGH + CRITICAL | 95.45% reduction |
| Unique CVEs | 96.76% reduction |

The improvement reflects the overall hardening process, including operating-system package updates and a reduced runtime package set.

**Finding count clarification:** Total findings represent package-level vulnerability detections. Unique CVEs count distinct vulnerability identifiers. These metrics are not interchangeable.

### Python dependencies

- Baseline image: 2 HIGH Python-package findings.
- Hardened image: 0 HIGH or CRITICAL Python-package findings.

### Residual risk

The hardened image still reports 49 HIGH findings across 13 unique CVEs, primarily associated with Debian operating-system packages.

The image is not vulnerability-free. Remaining findings should be reviewed and rescanned as upstream security fixes become available.

The baseline and hardened images also use different Debian point releases, so the results represent the overall hardening process rather than the effect of a single Dockerfile modification.

---

## 11. Security Reports

Trivy scan reports are maintained as project evidence:

- `trivy-baseline.json`
- `trivy-baseline.txt`
- `trivy-hardened.json`

The repository reports were synchronized with the latest comparative scan results generated on 7 November 2026 using Trivy 0.74.0.

Both JSON reports contain the detailed vulnerability findings and image metadata. The baseline text report provides a human-readable summary of the baseline scan.

The original report files were backed up before synchronization.
---

## 12. Git Workflow

The project uses Git and GitHub for source-code management.

Initialize Git:

```bash
git init
```

Create the main branch:

```bash
git branch -M main
```

Add changes:

```bash
git add .
```

Commit changes:

```bash
git commit -m "Description of changes"
```

Push changes:

```bash
git push origin main
```

GitHub repository:

https://github.com/BN-sahu/CloudDock

---

## 13. GitHub Actions CI/CD Pipeline

CloudDock uses GitHub Actions to automate Docker image building, vulnerability scanning, security gating, and container image publishing.

### Implemented workflow

1. A push to the main branch, pull request, or manual workflow trigger starts the pipeline.
2. GitHub Actions checks out the repository.
3. The hardened Docker image is built.
4. Trivy scans the image for HIGH and CRITICAL vulnerabilities.
5. A separate security gate checks for CRITICAL findings.
6. Successful non-pull-request runs publish the image to GitHub Container Registry (GHCR).
7. Trivy scan reports are uploaded as GitHub Actions artifacts.

### Security policy

- HIGH findings are reported but do not block the pipeline.
- CRITICAL findings cause the security gate to fail.
- Pull requests run build and security checks but do not publish images.
- Non-pull-request runs can publish the image to GHCR after the security checks pass.

The workflow uses GitHub Actions permissions and `GITHUB_TOKEN` for GHCR authentication.

---

## 14. Slack and Webhook Notifications

The GitHub Actions workflow includes Slack webhook notification steps for successful and failed pipeline runs.

Notifications can include:

- Repository name.
- Commit identifier.
- Pipeline result.
- Container image reference on success.
- GitHub Actions run link.

The workflow reads the webhook URL from the `SLACK_WEBHOOK_URL` GitHub Actions secret.

This secret must be configured in the repository settings for actual Slack message delivery. If delivery fails, the workflow reports a warning rather than treating the notification failure as a successful delivery.

Webhook credentials must never be committed to the repository.

A successful pipeline notification indicates that the configured workflow completed successfully. It does not mean that the image has zero vulnerabilities.

---

## 15. Future AWS Deployment

AWS deployment is a planned future extension and is not part of the currently implemented workflow.

A future deployment stage may:

1. Configure the required AWS environment.
2. Select an appropriate deployment service.
3. Retrieve the validated container image from GHCR or another supported registry.
4. Deploy the application.
5. Verify application health.
6. Configure monitoring and rollback mechanisms.

The current project demonstrates local Docker deployment, container hardening, vulnerability scanning, and GitHub Actions automation.

AWS credentials and deployment infrastructure are not required for the current workflow.

---

## 16. Security Principles

CloudDock follows these security principles:

- Least privilege.
- Non-root container execution.
- Minimal runtime environment.
- Automated vulnerability scanning.
- Security before deployment.
- Secrets stored outside source code.
- Repeatable CI/CD.
- Documented residual risk.

---

## 17. Limitations

CloudDock is currently a development and educational project.

Known limitations include:

- The hardened image still reports 49 HIGH vulnerability findings across 13 unique CVEs in the 7 November 2026 scan.
- Some remaining findings originate from Debian operating-system packages.
- Vulnerabilities without available upstream fixes may remain until updated packages become available.
- The CI security gate blocks CRITICAL findings, while HIGH findings are reported but do not fail the pipeline.
- Slack notification delivery depends on configuring and validating the `SLACK_WEBHOOK_URL` GitHub Secret.
- AWS deployment is not yet implemented.
- Production-grade zero-downtime deployment requires additional infrastructure, monitoring, and rollback mechanisms.

---

## 18. Future Enhancements

Future versions may include:

- More granular vulnerability thresholds and policy enforcement in CI/CD.
- Container image signing.
- SBOM generation and validation.
- Dependency update automation.
- Centralized security monitoring.
- AWS infrastructure automation using Terraform.
- Health checks and rollback mechanisms.
- Blue-green or rolling deployments.
- Improved observability and logging.

---

## 19. Team

CloudDock is being developed as a collaborative project.

**Team Members:**

- Badri Narayan Sahu
- Prithyu Ram B.

---

## 20. License

This project is developed for academic and educational purposes.

License information can be added when the project team selects an open-source license.
