# CloudDock

## Secure Containerized Cloud Deployment Platform

CloudDock is a security-focused cloud deployment project that demonstrates how a containerized web application can be built, hardened, scanned for vulnerabilities, and integrated into a secure CI/CD workflow.

The project focuses on improving container security before application deployment by using Docker hardening practices and Trivy vulnerability scanning.

---

## 1. Project Overview

Modern cloud applications are frequently deployed using containers because containers provide portability, consistency, and efficient resource usage.

CloudDock addresses container security by introducing the following workflow:

Application
    |
    v
Docker Container
    |
    v
Baseline Security Scan
    |
    v
Container Hardening
    |
    v
Hardened Image
    |
    v
Trivy Security Scan
    |
    v
CI/CD Pipeline
    |
    +------> Slack/Webhook Notification
    |
    v
AWS Deployment

The goal is to identify and reduce security risks before a container is deployed to the cloud.

---

## 2. Objectives

The main objectives of CloudDock are:

- Containerize a Python Flask application using Docker.
- Establish a baseline vulnerability profile for the container.
- Harden the Docker image using security best practices.
- Run automated vulnerability scanning using Trivy.
- Run the application using a non-root container user.
- Use a multi-stage Docker build.
- Integrate security scanning into GitHub Actions.
- Send build and security notifications through Slack/Webhooks.
- Deploy the validated container to AWS.
- Establish a repeatable and security-aware CI/CD workflow.

---

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Python | Application development |
| Flask | Web application framework |
| Docker | Application containerization |
| Trivy | Container vulnerability scanning |
| Git | Version control |
| GitHub | Source code repository |
| GitHub Actions | CI/CD automation |
| Slack/Webhook | Build and security notifications |
| AWS | Cloud deployment |

---

## 4. Project Status

### Completed

- [x] Flask application
- [x] Docker containerization
- [x] Multi-stage Docker build
- [x] Non-root container execution
- [x] Docker .dockerignore
- [x] Git .gitignore
- [x] Baseline Trivy vulnerability scan
- [x] Hardened Docker image
- [x] Hardened Trivy vulnerability scan
- [x] Trivy security reports
- [x] GitHub repository
- [x] Main branch

### In Progress

- [ ] GitHub Actions CI/CD pipeline
- [ ] Trivy integration into CI
- [ ] Slack/Webhook notifications
- [ ] Docker image registry workflow
- [ ] AWS deployment
- [ ] Deployment monitoring
- [ ] Zero/minimal-downtime deployment strategy

---

## 5. Project Structure

```text
CloudDock/
|
|-- app/
|   |-- app.py
|
|-- .github/
|   |-- workflows/
|
|-- Dockerfile
|-- .dockerignore
|-- .gitignore
|-- README.md
|-- requirements.txt
|
|-- trivy-baseline.json
|-- trivy-baseline.txt
|-- trivy-hardened.json
6. Docker Architecture

CloudDock uses a multi-stage Docker build.

Stage 1 - Builder

The builder stage:

Creates a Python virtual environment.
Installs the required Python dependencies.
Keeps dependency installation separate from the final runtime image.
Stage 2 - Runtime

The runtime stage:

Uses the Python slim image.
Copies the virtual environment from the builder.
Copies the application.
Creates a dedicated appuser.
Runs the application without root privileges.

This approach reduces unnecessary build artifacts in the runtime environment and improves container security.

7. Security Hardening

CloudDock applies several container security practices.

Non-root execution

The application runs as:

appuser

instead of the root user.

This reduces the impact of a potential application compromise.

Verify the container user with:

docker run --rm clouddock-app:hardened id

Expected result:

uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)
Multi-stage build

The Dockerfile separates dependency installation from the final runtime environment.

Minimal runtime image

The runtime uses a slim Python base image and copies the application environment from the builder.

Docker ignore rules

The .dockerignore file prevents unnecessary files such as the following from being included in the Docker build context:

venv/
__pycache__/
*.pyc
.git/
.github/
8. Running the Application
Run directly with Python

Activate the virtual environment:

source venv/bin/activate

Install dependencies:

pip install -r requirements.txt

Run the application:

python app/app.py
Run using Docker

Build the image:

docker build -t clouddock-app:hardened .

Run the container:

docker run --rm -p 5000:5000 --name clouddock-hardened clouddock-app:hardened

The application can then be accessed at:

http://localhost:5000

9. Trivy Security Scanning

Trivy is used to identify known vulnerabilities in the container image.

Baseline scan
trivy image --timeout 20m --severity HIGH,CRITICAL clouddock-app:baseline
Hardened scan
trivy image --timeout 20m --severity HIGH,CRITICAL clouddock-app:hardened
Critical vulnerabilities only
trivy image --timeout 20m --severity CRITICAL clouddock-app:hardened
10. Security Results

The baseline image produced:

HIGH     = 497
CRITICAL = 56
----------------
HIGH/CRITICAL = 553

The hardened image produced:

HIGH     = 51
CRITICAL = 3
----------------
HIGH/CRITICAL = 54

This demonstrates a substantial reduction in HIGH and CRITICAL vulnerability findings after container hardening.

Python dependencies

The hardened image currently reports:

CRITICAL Python vulnerabilities = 0

The remaining CRITICAL findings originate from the Debian perl-base package in the base operating system.

The available Debian package repository currently provides the same installed version, and Trivy does not report a fixed version for these findings.

Therefore, the remaining findings are documented as residual risk rather than removing an essential Debian package solely to obtain a zero-vulnerability scan.

CloudDock does not claim that the hardened image is completely vulnerability-free.

11. Security Reports

Trivy scan results are stored in the repository:

trivy-baseline.json
trivy-baseline.txt
trivy-hardened.json

These files provide evidence of the security scanning and hardening process.

12. Git Workflow

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

13. Planned CI/CD Pipeline

The next stage of CloudDock introduces GitHub Actions.

The planned workflow is:

Git Push
|
v
GitHub Actions
|
v
Build Docker Image
|
v
Trivy Security Scan
|
+----------------------+
| |
v v
Security Pass Security Fail
| |
v v
Push Image Block Push
| |
v v
Deploy to AWS Slack/Webhook Alert
|
v
Deployment Success
|
v
Slack/Webhook Notification

The CI/CD pipeline will use security checks before allowing an image to progress through the deployment workflow.

14. Slack and Webhook Notifications

CloudDock will use webhook-based notifications to provide visibility into CI/CD and security events.

Example security failure notification:

CLOUDDOCK SECURITY ALERT

Repository: CloudDock
Image: clouddock-app:hardened

CRITICAL: 3
HIGH: 51

Deployment: BLOCKED
Reason: Security scan failure

Example successful deployment notification:

CLOUDDOCK DEPLOYMENT SUCCESSFUL

Repository: CloudDock
Environment: AWS

Security Scan: Passed
Deployment: Successful

Webhook credentials will be stored as GitHub Secrets and will not be committed to the repository.

15. AWS Deployment

The planned cloud deployment environment is AWS.

The deployment stage will:

Build the validated Docker image.
Push the image to the selected container registry.
Configure the AWS environment.
Pull the approved image.
Start the application container.
Verify application health.
Report deployment status.
16. Security Principles

CloudDock follows these security principles:

Least privilege
Non-root container execution
Minimal runtime environment
Automated vulnerability scanning
Security before deployment
Secrets stored outside source code
Repeatable CI/CD
Documented residual risk
17. Limitations

CloudDock is currently a development and educational project.

Known limitations include:

Some vulnerabilities originate from the underlying Debian base image.
Not every vulnerability reported by a scanner can be immediately fixed when no upstream fixed version is available.
AWS deployment and automated CI/CD are still being implemented.
Production-grade zero-downtime deployment requires additional infrastructure and health-check mechanisms.
18. Future Enhancements

Future versions may include:

Automated vulnerability thresholds in CI/CD.
Container image signing.
SBOM generation and validation.
Dependency update automation.
Centralized security monitoring.
AWS infrastructure automation using Terraform.
Health checks and rollback mechanisms.
Blue-green or rolling deployments.
Improved observability and logging.
19. Team

CloudDock is being developed as a collaborative project.

Team responsibilities include:

Application development
Containerization and security hardening
CI/CD automation
Security scanning
Slack/Webhook integration
Cloud deployment
Documentation and testing
20. License

This project is developed for educational and project demonstration purposes.
