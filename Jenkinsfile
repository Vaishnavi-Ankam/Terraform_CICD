pipeline {
    agent any
   environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key')  
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')  
    }
    stages {
        stage('clone') {
            steps {
                git branch: 'main', url: 'https://github.com/Vaishnavi-Ankam/Terraform_CICD.git'
            }
        }
        stage('init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('apply') {
            steps {
                sh 'terraform apply -auto-approve'  
            }
        }
    }
}
