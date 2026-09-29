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

        stage('Update Kubernetes Manifests') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'github-credentials',
            usernameVariable: 'GIT_USERNAME',
            passwordVariable: 'GIT_PASSWORD'
        )]) {
            sh """
                git config user.name "Jenkins CI"
                git config user.email "shubhamnath5@gmail.com"

                sed -i "s|image: shubhamkah/ecommerce-app:.*|image: shubhamkah/ecommerce-app:${DOCKER_IMAGE_TAG}|g" k8s/08-ecommerce-deployment.yml
                sed -i "s|image: shubhamkah/ecommerce-migration:.*|image: shubhamkah/ecommerce-migration:${DOCKER_IMAGE_TAG}|g" k8s/12-migration-job.yml

                if git diff --quiet; then
                    echo "No changes to commit"
                else
                    git add k8s/*.yml
                    git commit -m "Update image tags to ${DOCKER_IMAGE_TAG} [ci skip]"
                    git remote set-url origin https://\${GIT_USERNAME}:\${GIT_PASSWORD}@github.com/Shubhamkahar196/ecommerce-devops-pipeline.git
                    git push origin HEAD:main
                fi
            """
        }
    }
}
    }
}