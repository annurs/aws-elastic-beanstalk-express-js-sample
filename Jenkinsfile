pipeline {
    agent none

    environment {
        DOCKER_IMAGE = 'annu22273745/assessment2'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
    }

    stages {

        stage('Install Dependencies') {
            agent {
                docker {
                    image 'node:16'
                    reuseNode true
                }
            }

            steps {
                echo 'Installing Node.js dependencies using Node 16...'
                sh 'node --version'
                sh 'npm --version'
                sh 'npm ci'
            }
        }

        stage('Unit Tests') {
            agent {
                docker {
                    image 'node:16'
                    reuseNode true
                }
            }

            steps {
                echo 'Running automated unit tests...'
                sh 'npm test'
            }
        }

        stage('Security Scan') {
            agent {
                docker {
                    image 'node:16'
                    reuseNode true
                }
            }

            steps {
                echo 'Running npm dependency vulnerability assessment...'

                sh 'npm audit --json > npm-audit.json || true'

                sh 'npm audit --audit-level=high'
            }

            post {
                always {
                    archiveArtifacts(
                        artifacts: 'npm-audit.json',
                        allowEmptyArchive: true
                    )
                }
            }
        }

        stage('Build Docker Image') {
            agent any

            steps {
                echo 'Building application Docker image...'

                sh '''
                    docker build \
                      -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                      -t ${DOCKER_IMAGE}:latest \
                      .
                '''
            }
        }

        stage('Push Docker Image') {
            agent any

            steps {
                echo 'Publishing Docker image to Docker Hub...'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | \
                        docker login \
                        -u "$DOCKER_USERNAME" \
                        --password-stdin

                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
        }

        failure {
            echo 'CI/CD pipeline failed. Review the failed stage and logs.'
        }

        always {
            archiveArtifacts(
                artifacts: 'npm-audit.json',
                allowEmptyArchive: true
            )
        }
    }
}
