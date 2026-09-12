# CloudDock

## Secure Containerized Cloud Deployment Platform

CloudDock is a security-focused cloud deployment project that demonstrates how a containerized web application can be built, hardened, scanned for vulnerabilities, and integrated into a secure CI/CD workflow.

The project focuses on improving container security before application deployment using Docker hardening practices and Trivy vulnerability scanning.

---

## 1. Project Overview

CloudDock introduces a security-focused workflow for containerized cloud applications.

**Workflow:**

Application → Docker Container → Baseline Scan → Container Hardening → Hardened Image → Trivy Scan → CI/CD → AWS Deployment

Slack/Webhook notifications will provide alerts for security and deployment events.

---

## 2. Objectives

The main objectives of CloudDock are:

- Containerize a Python Flask application using Docker.
- Establish a baseline vulnerability profile.
- Harden the Docker image.
- Scan container images using Trivy.
- Run the application as a non-root user.
- Use a multi-stage Docker build.
- Integrate security scanning into GitHub Actions.
- Send security and deployment notifications through Slack/Webhooks.
- Deploy the validated container to AWS.
- Build a repeatable security-focused CI/CD workflow.

---

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Python | Application development |
| Flask | Web application framework |
| Docker | Containerization |
| Trivy | Vulnerability scanning |
| Git | Version control |
| GitHub | Source code repository |
| GitHub Actions | CI/CD automation |
| Slack/Webhook | Notifications |
| AWS | Cloud deployment |

---

## 4. Project Status

### Completed

- [x] Flask application
- [x] Docker containerization
- [x] Multi-stage Docker build
- [x] Non-root container execution
- [x] Docker `.dockerignore`
- [x] Git `.gitignore`
- [x] Baseline Trivy scan
- [x] Hardened Docker image
- [x] Hardened Trivy scan
- [x] Trivy security reports
- [x] GitHub repository
- [x] Main branch

### In Progress

- [ ] GitHub Actions CI/CD pipeline
- [ ] Trivy integration into CI
- [ ] Slack/Webhook notifications
- [ ] Container registry workflow
- [ ] AWS deployment
- [ ] Deployment monitoring
- [ ] Zero/minimal-downtime deployment strategy

---

## 5. Project Structure

The current project structure is:

    CloudDock/
    ├── app/
    │   └── app.py
    ├── .github/
    │   └── workflows/
    ├── Dockerfile
    ├── .dockerignore
    ├── .gitignore
    ├── README.md
    ├── requirements.txt
    ├── trivy-baseline.json
    ├── trivy-baseline.txt
    └── trivy-hardened.json

---

## 6. Docker Architecture

CloudDock uses a multi-stage Docker build.

### Stage 1 - Builder

The builder stage:

- Creates a Python virtual environment.
- Installs application dependencies.
- Keeps dependency installation separate from the runtime image.

### Stage 2 - Runtime

The runtime stage:

- Uses the Python slim image.
- Copies the virtual environment from the builder.
- Copies the application.
- Creates a dedicated `appuser`.
- Runs the application without root privileges.

This approach helps reduce unnecessary build artifacts and improves container security.

---

## 7. Security Hardening

CloudDock applies several container security practices.

### Non-root execution

The application runs as `appuser` instead of root.

Verify this with:

    docker run --rm clouddock-app:hardened id

Expected result:

    uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)

### Multi-stage build

The Dockerfile separates dependency installation from the final runtime environment.

### Slim runtime image

The runtime uses a Python slim base image and copies the application environment from the builder.

### Docker ignore rules

The `.dockerignore` file excludes unnecessary files such as:

- `venv/`
- `__pycache__/`
- `*.pyc`
- `.git/`
- `.github/`

---

## 8. Running the Application

### Run directly with Python

Activate the virtual environment:

    source venv/bin/activate

Install dependencies:

    pip install -r requirements.txt

Run the application:

    python app/app.py

### Run using Docker

Build the image:

    docker build -t clouddock-app:hardened .

Run the container:

    docker run --rm -p 5000:5000 --name clouddock-hardened clouddock-app:hardened

The application can then be accessed at:

**http://localhost:5000**

---

## 9. Trivy Security Scanning

Trivy is used to identify known vulnerabilities in container images.

### Baseline scan

    trivy image --timeout 20m --severity HIGH,CRITICAL clouddock-app:baseline

### Hardened scan

    trivy image --timeout 20m --severity HIGH,CRITICAL clouddock-app:hardened

### Critical vulnerabilities only

    trivy image --timeout 20m --severity CRITICAL clouddock-app:hardened

---

## 10. Security Results

The baseline image produced:

| Severity | Findings |
|---|---:|
| HIGH | 497 |
| CRITICAL | 56 |
| **HIGH + CRITICAL** | **553** |

The hardened image produced:

| Severity | Findings |
|---|---:|
| HIGH | 51 |
| CRITICAL | 3 |
| **HIGH + CRITICAL** | **54** |

This demonstrates a substantial reduction in HIGH and CRITICAL vulnerability findings after container hardening.

### Python dependencies

The hardened image currently reports:

**CRITICAL Python vulnerabilities: 0**

The remaining CRITICAL findings originate from the Debian `perl-base` package in the base operating system.

The available Debian repository currently provides the same installed package version, and Trivy does not report a fixed version for these findings.

Therefore, these findings are documented as residual risk rather than removing an essential Debian package solely to obtain a zero-vulnerability scan.

CloudDock does not claim that the hardened image is completely vulnerability-free.

---

## 11. Security Reports

Trivy scan results are stored in the repository:

- `trivy-baseline.json`
- `trivy-baseline.txt`
- `trivy-hardened.json`

These reports provide evidence of the security scanning and hardening process.

---

## 12. Git Workflow

The project uses Git and GitHub for source-code management.

Initialize Git:

    git init

Create the main branch:

    git branch -M main

Add changes:

    git add .

Commit changes:

    git commit -m "Description of changes"

Push changes:

    git push origin main

GitHub repository:

https://github.com/BN-sahu/CloudDock

---

## 13. Planned CI/CD Pipeline

The next stage of CloudDock introduces GitHub Actions.

**Planned workflow:**

Git Push  
↓  
GitHub Actions  
↓  
Build Docker Image  
↓  
Trivy Security Scan  
↓  
Security Decision  
↓  
Security Pass → Push Image → AWS Deployment  
Security Fail → Block Deployment → Slack/Webhook Alert

The CI/CD pipeline will use security checks before allowing an image to progress through the deployment workflow.

---

## 14. Slack and Webhook Notifications

CloudDock will use webhook-based notifications for CI/CD and security events.

### Security failure

Example notification:

**CLOUDDOCK SECURITY ALERT**

- Repository: CloudDock
- Image: clouddock-app:hardened
- CRITICAL: 3
- HIGH: 51
- Deployment: BLOCKED
- Reason: Security scan failure

### Successful deployment

Example notification:

**CLOUDDOCK DEPLOYMENT SUCCESSFUL**

- Repository: CloudDock
- Environment: AWS
- Security Scan: Passed
- Deployment: Successful

Webhook credentials will be stored as GitHub Secrets and will never be committed to the repository.

---

## 15. AWS Deployment

The planned cloud deployment environment is AWS.

The deployment stage will:

1. Build the validated Docker image.
2. Push the image to the selected container registry.
3. Configure the AWS environment.
4. Pull the approved image.
5. Start the application container.
6. Verify application health.
7. Report deployment status.

---

## 16. Security Principles

CloudDock follows these security principles:

- Least privilege
- Non-root container execution
- Minimal runtime environment
- Automated vulnerability scanning
- Security before deployment
- Secrets stored outside source code
- Repeatable CI/CD
- Documented residual risk

---

## 17. Limitations

CloudDock is currently a development and educational project.

Known limitations include:

- Some vulnerabilities originate from the underlying Debian base image.
- Not every vulnerability can be immediately fixed when no upstream fixed version is available.
- AWS deployment and automated CI/CD are still being implemented.
- Production-grade zero-downtime deployment requires additional infrastructure and health-check mechanisms.

---

## 18. Future Enhancements

Future versions may include:

- Automated vulnerability thresholds in CI/CD.
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

Team responsibilities include:

- Application development
- Containerization and security hardening
- CI/CD automation
- Security scanning
- Slack/Webhook integration
- Cloud deployment
- Documentation and testing

---

## 20. License

This project is developed for educational and project demonstration purposes.
