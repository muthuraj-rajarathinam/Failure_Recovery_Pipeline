## 🚀 Failure Recovery CI/CD Pipeline with Jenkins, Node.js, EC2 and AWS SNS

Failure Recovery CI/CD Pipeline is a robust, production-ready Jenkins CI/CD pipeline that automatically deploys a Node.js app to an EC2 instance with built-in health checks, SNS alerts, and rollback on failure.

This project demonstrates:
```
✅ Automated deployment via Jenkins
❤️ Health check to validate app uptime
⚠️ Auto rollback using Git if health check fails
📬 AWS SNS integration for success/failure notifications
💻 End-to-end scripting (build.sh, deploy.sh, rollback.sh, etc.)
```

It's built to ensure zero-downtime, self-healing deployments — ideal for real-world production environments.

## 📦 Features

* ✅ Clones source code from GitHub
* 🔧 Builds and deploys a Node.js app
* 🧪 Performs health checks
* 📉 Automatically rolls back on failure
* 📬 Sends email notifications via AWS SNS

---

## 🧰 Prerequisites

* AWS account
* IAM user with EC2, SNS, and IAM permissions
* GitHub account
* Basic knowledge of Linux and shell scripting

---

## 📁 Project Structure

```
Failure_Recovery_Pipeline/
│
├── App.js                # 🟢 Simple Node.js app (listens on port 3000)
├── build.sh              # 🛠️ Installs required Node.js dependencies
├── deploy.sh             # 🚀 Deploys the Node.js app and runs it in background
├── healthcheck.sh        # ❤️ Performs health check on deployed app
├── rollback.sh           # ⏪ Rolls back to previous stable commit if health check fails
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

---

### 🔹 Step 2: Connect to EC2

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@your-ec2-public-ip
```

---

### 🔹 Step 3: Install Essentials

```bash
sudo yum update -y
sudo yum install git unzip curl wget -y
```

---

### 🔹 Step 4: Install Java (Jenkins Dependency)

```bash
sudo amazon-linux-extras install java-openjdk11 -y
java -version  # Verify Java installation
```

---

### 🔹 Step 5: Install Jenkins

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

---

### 🔹 Step 6: Access Jenkins Dashboard

* Visit: `http://<EC2_PUBLIC_IP>:8080`
* Unlock Jenkins:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

* Install suggested plugins
* Create your admin user

---

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

---

### 🔹 Step 9: Add CI/CD Shell Scripts

Create the following files in your repo:

* `build.sh` – Installs dependencies
* `deploy.sh` – Starts Node.js app
* `rollback.sh` – Git rollback + restart
* `healthcheck.sh` – Performs curl check
* `send-sns-success.sh` – SNS email for success
* `send-sns-failure.sh` – SNS email for failure

Make them executable:

```bash
chmod +x *.sh
```

---

### 🔹 Step 10: Push Code to GitHub

```bash
git init
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git add .
git commit -m "Initial commit"
git push -u origin master
```

---

## 🔐 Configure AWS IAM + SNS

### 🔹 Step 11: Create SNS Topic

* AWS Console → SNS → Create Topic
* Add your email as subscriber and confirm email

### 🔹 Step 12: Create IAM Role for EC2

* Go to IAM → Roles → Create Role
* Select EC2 as use case
* Attach custom policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "arn:aws:sns:REGION:ACCOUNT_ID:TOPIC_NAME"
    }
  ]
}
```

* Attach the role to your EC2 instance

---

## ⚙️ Jenkins Pipeline Configuration

### 🔹 Step 13: Create a New Pipeline Job

* In Jenkins → New Item → Pipeline → Name it `Failure_Recovery_Pipeline`

Paste the following in the Pipeline script section:

```groovy
pipeline {
    agent any

    environment {
        APP_DIR = "$WORKSPACE"
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

        stage('Deploy') {
            steps {
                sh 'chmod +x deploy.sh'
                sh './deploy.sh'
            }
        }

        stage('Health Check') {
            steps {
                script {
                    def result = sh(script: "curl -f http://localhost:3000/health", returnStatus: true)
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

## 🧪 Testing Failure Scenario

1. In your app, change `PORT` to a non-matching one (e.g., 9999)
2. Commit and push to GitHub
3. Trigger the Jenkins job
4. Jenkins will fail the health check and:

   * Call `rollback.sh`
   * Restore the last working commit
   * Send failure email via SNS

---

## ✅ You're All Set!

You now have a working full CI/CD pipeline that:

* Builds and deploys code from GitHub
* Checks app health
* Rolls back on failure
* Sends success/failure alerts via email using AWS SNS
