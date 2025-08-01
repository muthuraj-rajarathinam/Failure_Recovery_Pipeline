# 🚀 Failure Recovery CI/CD Pipeline with Jenkins

Failure Recovery CI/CD Pipeline is a robust, production-ready Jenkins CI/CD pipeline that automatically deploys a Node.js app to an EC2 instance with built-in health checks, SNS alerts, and rollback using local backups on EC2.

This project demonstrates:  
```
✅ Automated deployment via Jenkins  
❤️ Health check to validate app uptime  
⚠️ Auto rollback by restoring backup on EC2 if health check fails  
📬 AWS SNS integration for success/failure notifications  
💻 End-to-end scripting (build.sh, deploy.sh, backup.sh, rollback.sh, etc.)  
```

It's built to ensure zero-downtime, self-healing deployments — ideal for real-world production environments.

## 📦 Features

* ✅ Clones source code from GitHub  
* 🔧 Builds and deploys a Node.js app  
* 🧪 Performs health checks  
* 📉 Automatically rolls back by restoring local EC2 backup on failure  
* 📬 Sends email notifications via AWS SNS  

## 🧰 Prerequisites

* AWS account  
* IAM user with EC2, SNS, and IAM permissions  
* GitHub account  
* Basic knowledge of Linux and shell scripting  

## 📁 Project Structure

```
Failure_Recovery_Pipeline/
│
├── App.js                # 🟢 Simple Node.js app (listens on port 3000)
├── build.sh              # 🛠️ Installs required Node.js dependencies
├── backup.sh             # 💾 Backs up the current app version on EC2 before deployment
├── deploy.sh             # 🚀 Deploys the Node.js app and runs it in background
├── healthcheck.sh        # ❤️ Performs health check on deployed app
├── rollback.sh           # ⏪ Restores app from backup on EC2 if health check fails
├── send-sns-success.sh   # 📬 Sends email via SNS on successful deployment
├── send-sns-failure.sh   # ⚠️ Sends email via SNS on failed deployment
```

## 🧱 Step-by-Step Setup

### 🔹 Step 1: Launch EC2 Instance

* Go to AWS EC2 Console  
* Launch a new EC2 instance with:

  * Amazon Linux 2  
  * t3.small (recommended)  
  * Create key pair in PEM format  
  * Configure Security Groups:

    * ✅ Port 22 (SSH)  
    * ✅ Port 8080 (Jenkins)  
    * ✅ Port 3000 (Node.js app)  

### 🔹 Step 2: Connect to EC2

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@your-ec2-public-ip
```

### 🔹 Step 3: Install Essentials

```bash
sudo yum update -y
sudo yum install git unzip curl wget -y
```

### 🔹 Step 4: Install Java (Jenkins Dependency)

```bash
sudo dnf install java-11-amazon-corretto -y
java -version  # Verify Java installation
```

### 🔹 Step 5: Install Jenkins

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

### 🔹 Step 6: Access Jenkins Dashboard

* Visit: `http://:8080`  
* Unlock Jenkins with password from Terminal using:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

* Install suggested plugins  
* Create your admin user  

## 💻 Set Up Your Node.js App

### 🔹 Step 7: Create App Directory in EC2

```bash
mkdir ~/myapp && cd ~/myapp
```

### 🔹 Step 8: Create `app.js`

Add a simple Node.js app, for example:

```js
const http = require('http');
const PORT = 3000;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200);
    res.end('OK');
  } else {
    res.writeHead(200);
    res.end('Hello from Node.js CI/CD Pipeline');
  }
});

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
```

### 🔹 Step 9: Add CI/CD Shell Scripts

Create the shell scripts (`build.sh`, `backup.sh`, `deploy.sh`, `healthcheck.sh`, `rollback.sh`, `send-sns-success.sh`, `send-sns-failure.sh`) in your repository and make them executable:

```bash
chmod +x *.sh
```

### 🔹 Step 10: Push Code to GitHub

```bash
git init                                                             # Initialize Git repo
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git # Add remote repo
git add .                                                            # Stage files
git commit -m "Initial commit"                                       # Commit changes
git push -u origin master                                            # Push code to GitHub
```

## 🔐 Configure AWS IAM + SNS

### 🔹 Step 11: Create SNS Topic

* AWS Console → SNS → Create Topic  
* Add your email as subscriber and confirm subscription  

### 🔹 Step 12: Create IAM Role for EC2

* Go to IAM → Roles → Create Role  
* Select EC2 as use case  
* Attach custom policy with SNS Publish permissions to your SNS Topic  

### 🔹 Step 13: Attach Role to EC2 Instance

## ⚙️ Jenkins Pipeline Configuration

### 🔹 Step 14: Create a New Pipeline Job in Jenkins

* In Jenkins → New Item → Pipeline → Name it `Failure_Recovery_Pipeline`  
* Paste the following Pipeline script:

```groovy
pipeline {
    agent any

    environment {
        APP_DIR = "/home/ec2-user/myapp"
        BACKUP_DIR = "/home/ec2-user/myapp_backup"
    }

    stages {
        stage('Clone') {
            steps {
                git 'https://github.com/YOUR_USERNAME/YOUR_REPO.git'
            }
        }

        stage('Build') {
            steps {
                sh 'chmod +x build.sh'
                sh './build.sh'
            }
        }

        stage('Backup Current Version') {
            steps {
                sh 'chmod +x backup.sh'
                sh './backup.sh'
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
                    def result = sh(script: 'chmod +x healthcheck.sh && ./healthcheck.sh', returnStatus: true)
                    if (result != 0) {
                        echo "App unhealthy. Rolling back..."
                        sh 'chmod +x rollback.sh'
                        sh './rollback.sh'
                        error("App failed health check, rollback done.")
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

## 🧪 Testing Failure Scenario

1. Modify your `app.js` or deployment so the health check will fail (e.g., change port or break endpoint)  
2. Commit and push changes to GitHub  
3. Trigger the Jenkins pipeline job manually  
4. Jenkins will detect health check failure and run rollback by restoring the last backup on EC2  
5. You will receive failure notification via SNS  

## ✅ You're All Set!

You now have a working, robust CI/CD pipeline that:  

* Clones, builds, and deploys your Node.js app  
* Performs health checks and validates uptime  
* Backs up the current app version on EC2 before deploying  
* Restores the app from local backup on EC2 if health check fails  
* Sends success and failure notifications through AWS SNS  

Enjoy zero downtime and reliable self-healing deployments in your environment!
