pipeline {
    agent any
    
    environment {
        JAVA_HOME = tool name: 'Java11', type: 'jdk'
        MAVEN_HOME = tool name: 'Maven', type: 'maven'
        DOCKER_HUB_CREDENTIALS = 'docker-hub-credentials' // Update with your Docker Hub credentials ID
        SONARQUBE_SERVER = 'SonarQube'
        ARTIFACTORY_SERVER = 'Artifactory'
    }
    
    tools {
        jdk 'Java11'
        maven 'Maven'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Pavan1403/jenkins-end-2-end-pipeline.git'
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
        
        stage('Docker Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_HUB_CREDENTIALS) {
                        sh 'docker tag myapp:${env.BUILD_ID} your-dockerhub-username/myapp:${env.BUILD_ID}'
                        sh 'docker push your-dockerhub-username/myapp:${env.BUILD_ID}'
                    }
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
