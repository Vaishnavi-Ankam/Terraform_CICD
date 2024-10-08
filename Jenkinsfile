pipeline {
    agent any

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
                sh 'terraform apply'
            }
        }
    }
}
