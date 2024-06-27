pipeline {
    agent any
    
    environment {
        JAVA_HOME = tool name: 'Java11', type: 'jdk'
        MAVEN_HOME = tool name: 'Maven', type: 'maven'
    }
    
    tools {
        jdk 'Java11'
        maven 'Maven'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    sh 'docker build -t myapp:${env.BUILD_ID} .'
                }
            }
        }
        
        stage('Minikube Deploy') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'minikube-kubeconfig']) {
                        sh '''
                            kubectl apply -f k8s/deployment.yaml
                        '''
                    }
                }
            }
        }
        
        stage('Ansible Deploy') {
            steps {
                ansiblePlaybook credentialsId: 'ansible-ssh-key', inventory: 'ansible/inventory', playbook: 'ansible/playbook.yml'
            }
        }
        
        stage('Publish to Artifactory') {
            steps {
                script {
                    def server = Artifactory.server 'Artifactory'
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "target/*.jar",
                                "target": "libs-release-local/myapp/${env.BUILD_ID}/"
                            }
                        ]
                    }"""
                    server.upload spec: uploadSpec
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
