pipeline {
    agent any
    
    environment {
        SCANNER_HOME = tool name: 'sonarqube', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
    }
    
    tools {
        jdk 'jdk-11'
        maven 'maven3'
        // Make sure 'SonarQube_Scanner' is configured in Global Tool Configuration in Jenkins
    }
    
    stages {
        stage('git checkout') {
            steps {
                git branch: 'main', changelog: false, credentialsId: 'Github-cred', poll: false, url: 'https://github.com/Prakash8618/jenkins-end-2-end-pipeline.git'
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
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'dp-check7'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
        stage('Sonar CODE ANALYSIS') {
            steps {
                script {
                    withSonarQubeEnv('sonar') {
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
