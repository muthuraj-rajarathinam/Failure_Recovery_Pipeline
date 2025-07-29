🚀 Failure Recovery CI/CD Pipeline with Jenkins, Node.js, EC2, and AWS SNS

This guide explains how to set up a Jenkins pipeline on an EC2 instance to deploy a Node.js application, perform health checks, send notifications via SNS, and automatically roll back on failure. 

The pipeline performs the following:
-Clones your GitHub repo
-Builds and deploys your app on an EC2 instance
-Performs a health check
   If the health check fails:
    ```
     Automatically rolls back to the previous commit
     Sends a failure notification via AWS SNS(Email)
    ```
   On success:
    ```
     Sends a success notification(Email)
    ```

Failure_Recovery_Pipeline/
│
├── build.sh              # Build script (currently installs dependencies)
├── deploy.sh             # Deploys the Node.js app
├── healthcheck.sh        # check the health 
├── rollback.sh           # Rollback script on failure
├── send-sns-success.sh   # SNS success email trigger
├── send-sns-failure.sh   # SNS failure email trigger
├── App.js            n   # Simple Node.js app
├── README.md             # Full project guide

---

## 🧰 Prerequisites

* AWS account
* IAM user with EC2, SNS, and IAM permissions
* GitHub account
* Basic knowledge of Linux and shell scripting

---

## 🧱 Step-by-Step Setup

### Step 1: Launch EC2 Instance

```bash
# Go to AWS EC2 Console
# Launch a new EC2 instance with:
# - Amazon Linux 2
# - t3.small (recommended)
# - Create key pair (PEM format)
# - Security Groups → Inbound Rules -> 22 (SSH), 8080 (Jenkins), 3000 (Node app)
```

### Step 2: Connect to EC2 using PEM in Gitbash

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@your-ec2-public-ip
```

### Step 3: Install Essentials

```bash
sudo yum update -y
sudo yum install git unzip curl wget -y
```

### Step 4: Install Java 17

```bash
sudo amazon-linux-extras install java-openjdk11 -y
java -version  # Check Java version
```

### Step 5: Install Jenkins

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y
sudo systemctl enable jenkins #enable and start jenkins
sudo systemctl start jenkins
```

### Step 6: Open Jenkins Dashboard

```bash
# Open http://EC2_PUBLIC_IP:8080 in your browser
# Get Jenkins password in gitbash terminal:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

* Install default plugins
* Create admin user

---

## 💻 Setup Node.js App and GitHub Repo

### Step 7: Create App Directory

```bash
mkdir ~/myapp && cd ~/myapp
```

### Step 8: Create Node App Files

create simple app code using nodejs -> app.js

### Step 9: Create CI/CD Scripts

```bash
# build.sh
# deploy.sh
# rollback.sh
# healthcheck.sh
# send-sns-success.sh
# send-sns-failure.sh
```

Make scripts executable:

```bash
chmod +x *.sh
```

### Step 10: Initialize Git Repo and Push to GitHub

```bash
git init                                                               #initialize github
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git   #connect github account
git add .                                                              # Stages all changes for commit
git commit -m "Initial commit"                                         # Saves changes with a message
git push -u origin master                                              # Pushes code to GitHub
```

---

## 🔐 IAM Role + SNS Setup

### Step 11: Create SNS Topic

```bash
# In AWS Console, create SNS topic and subscribe with your email.
# Confirm email subscription.
```

### Step 12: Create IAM Role for EC2

* IAM > Roles > Create Role
* Use Case: EC2
* Attach Policies: `AmazonSNSFullAccess`
* Attach to EC2 instance

### Step 13: Configure AWS CLI on EC2

```bash
aws configure
# Provide IAM user access key (optional if using instance role)
```

---

## ⚙️ Jenkins Pipeline Setup

### Step 14: Create New Pipeline Job in Jenkins

```groovy
pipeline {
    agent any

    environment {
        APP_DIR = "$WORKSPACE"
    }

    stages {
        stage('Clone') {
            steps {
                git 'https://github.com/YOUR_USERNAME/YOUR_REPO.git'  # Clone GitHub repo
            }
        }

        stage('Build') {
            steps {
                sh 'chmod +x build.sh'
                sh './build.sh'
            }
        }

        stage('Deploy') {
            steps {
                sh 'chmod +x deploy.sh'
                sh './deploy.sh'
            }
        }

        stage('Health Check') {
            steps {
                script {
                    def result = sh(script: "curl -f http://localhost:3000", returnStatus: true)
                    if (result != 0) {
                        echo "App unhealthy. Rolling back..."
                        sh './rollback.sh'
                        error("App failed health check")
                    } else {
                        echo "Health check passed ✅"
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful 🎉'
            sh './send-sns-success.sh'
        }
        failure {
            echo 'Deployment failed ❌'
            sh './send-sns-failure.sh'
        }
    }
}
```

---

## 🧪 To Test Failure:

* Change port in `server.js` to a wrong one (e.g. `PORT = 9999`) and push to GitHub.
* Trigger pipeline again.
* It will fail the health check and run `rollback.sh`
* Email notification will be sent via SNS.

---

## 📸 GitHub Project Images for Portfolio

Include:

* Jenkins Dashboard screenshot (with pipeline stages)
* EC2 instance running app (`curl localhost:3000`)
* GitHub repo screenshot
* Terminal logs showing success and rollback
* Email notification screenshot

---

## ✅ Done!

You now have a working CI/CD pipeline with automatic failure recovery and SNS notifications.


