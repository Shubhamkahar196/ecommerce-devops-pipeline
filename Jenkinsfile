pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME           = "shubhamkah/ecommerce-app"
        DOCKER_MIGRATION_IMAGE_NAME = "shubhamkah/ecommerce-migration"
        DOCKER_IMAGE_TAG            = "${BUILD_NUMBER}"
        DOCKERHUB_CREDENTIALS       = credentials("docker-hub-credentials")
        GITHUB_CREDENTIALS          = credentials('github-credentials')
        GIT_BRANCH                  = "main"
    }

    stages {
        stage("Cleanup Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("Clone Repository") {
            steps {
                git branch: 'main', url: "https://github.com/Shubhamkahar196/ecommerce-devops-pipeline.git"
            }
        }

        stage("Build Docker Images") {
            parallel {
                stage("Build Main app Image") {
                    steps {
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} -f Dockerfile ."
                    }
                }
                stage("Build Migration Image") {
                    steps {
                        sh "docker build -t ${DOCKER_MIGRATION_IMAGE_NAME}:${DOCKER_IMAGE_TAG} -f scripts/Dockerfile.migration ."
                    }
                }
            }
        }

        stage("Run Unit tests") {
            steps {
                sh "npm install && npm test"
            }
        }

        stage("Security scan with Trivy") {
            steps {
                sh "trivy image ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} --severity HIGH,CRITICAL --exit-code 0"
            }
        }

        stage("Push Docker Images") {
            parallel {
                stage("Push main app image") {
                    steps {
                        sh """
                            echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                            docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                        """
                    }
                }
                stage("Push migration Image") {
                    steps {
                        sh "docker push ${DOCKER_MIGRATION_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy to kubernetes') {
            steps {
                sh """
                    kubectl set image deployment/ecommerce-app ecommerce-app=${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                """
            }
        }
    }
}