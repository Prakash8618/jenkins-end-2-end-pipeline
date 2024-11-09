pipeline {
    agent any
    
    environment {
        SCANNER_HOME = tool name: 'sonarqube', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
    }
    
    tools {
        jdk 'jdk-11'
        maven 'maven3'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', changelog: false, credentialsId: 'Github-cred', poll: false, url: 'https://github.com/Prakash8618/jenkins-end-2-end-pipeline.git'
            }
        }
        stage('Maven Compile') {
            steps {
                sh 'mvn clean compile'
            }
        }
        
        stage('Maven Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('OWASP Scan') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'dp-check7'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
        stage('Sonar Code Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonar') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Publish to Artifactory') {
            steps {
                script {
                    def server = Artifactory.server 'jfrogserver'
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "target/*.jar",
                                "target": "example-repo-local/myapp/${env.BUILD_ID}/"
                            }
                        ]
                    }"""
                    def buildInfo = server.upload spec: uploadSpec
                    server.publishBuildInfo buildInfo
                }
            }
        }
        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'Docker-cred', url: '']) {
                        sh '''
                        docker build -t e2ejenkins .
                        docker tag e2ejenkins prakash8618/e2ejenkins:latest
                        docker push prakash8618/e2ejenkins:latest
                        '''
                    }
                }
            }
        }
        stage('Debug Kubernetes Config') {
            steps {
                sh 'kubectl config view'
                sh 'kubectl config get-contexts'
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                script {
                    // Set the Kubernetes context to the correct context name
                    // sh 'KUBECONFIG=/var/lib/jenkins/.kube/config && kubectl config use-context Project_pipeline'  // Use the correct context name
                       sh 'aws eks update-kubeconfig --name Project_pipeline --region us-east-1 && KUBECONFIG=/var/lib/jenkins/.kube/config'
                    // Deploy to Kubernetes
                    try {
                        sh '''
                        cd /var/lib/jenkins/workspace/Java-app-pipeline/k8s
                        kubectl apply -f deployment.yaml --validate=false
                        kubectl apply -f service.yaml --validate=false
                        '''
                    } catch (Exception e) {
                        error("Kubernetes deployment failed: ${e.message}")
                    }
                }
            }
        }
    }
}
