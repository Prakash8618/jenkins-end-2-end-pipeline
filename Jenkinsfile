pipeline {
    agent any
    
    environment {
        SCANNER_HOME = tool name: 'SonarQube_Scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
    }
    
    tools {
        jdk 'Java17'
        maven 'Maven3.9'
        // Make sure 'SonarQube_Scanner' is configured in Global Tool Configuration in Jenkins
    }
    
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', changelog: false, credentialsId: 'Git_Cred', poll: false, url: 'https://github.com/Pavan1403/jenkins-end-2-end-pipeline.git'
            }
        }
        
        stage('Maven COMPILE') {
            steps {
                sh 'mvn clean compile'
            }
        }
        
        stage('Maven TEST') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('OWASP SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'DP7'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
        stage('Sonar CODE ANALYSIS') {
            steps {
                script {
                    withSonarQubeEnv('sonarqube') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
        
        stage('Maven BUILD') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('PUBLISH to Artifactory') {
            steps {
                script {
                    def server = Artifactory.server('Artifactory')
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
        
        stage('Docker BUILD & PUSH') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'DockerHub_Cred', url: '']) {
                        sh "docker build -t e2ejenkins ."
                        sh "docker tag e2ejenkins prakash8618/e2ejenkins:latest"
                        sh "docker push prakash8618/e2ejenkins:latest"
                    }
                }
            }
        }
    }
}
