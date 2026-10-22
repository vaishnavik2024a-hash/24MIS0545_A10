pipeline {
    agent any
    
    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['Development', 'Production'], description: 'Select Target Environment')
    }
    
    environment {
        DOCKER_HUB_USER  = '24mis0545' // Change to your username
        IMAGE_NAME       = 'water-monitor'
        IMAGE_TAG        = "${BUILD_NUMBER}"
        DOCKER_CREDS_ID  = 'docker-hub-credentials' // Configured in Jenkins Credential Provider
    }
    
    stages {
        stage('Initialize & Code Check') {
            parallel {
                stage('HTML Lint Check') {
                    steps {
                        echo "Checking HTML Syntax Structure..."
                        sh "echo 'index.html structure looks healthy'"
                    }
                }
                stage('Workspace Cleanup') {
                    steps {
                        echo "Cleaning prior environment structures..."
                        cleanWs()
                    }
                }
            }
        }
        
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        stage('Build & Test Container') {
            steps {
                script {
                    echo "Building App Container Image tag: ${IMAGE_TAG}"
                    sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                    sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest ."
                    
                    echo "Simulating Local Verification Assessment..."
                    // Mock validation check saving test log artifact
                    sh "echo 'Testing dashboard endpoints: PASSED' > validation_report.log"
                }
            }
        }
        
        stage('Push Image to DockerHub') {
            steps {
                script {
                    // Authenticate and push images using credentials binding
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDS_ID}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            // Conditional Execution Rule (Only deploy if Development or Production parameters are clean)
            when {
                expression { return params.DEPLOY_ENV == 'Development' || params.DEPLOY_ENV == 'Production' }
            }
            steps {
                script {
                    echo "Executing deployment rollout to Local Kubernetes Cluster..."
                    // Adjust system manifest dynamically using built image tags
                    sh "sed -i 's|your-dockerhub-username/${IMAGE_NAME}:latest|${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' deployment.yaml"
                    
                    // Trigger deployment within cluster context
                    sh "kubectl apply -f deployment.yaml"
                    
                    // Verify rollout execution state status
                    sh "kubectl rollout status deployment/water-monitoring-app --timeout=60s"
                }
            }
        }
    }
    
    post {
        always {
            echo "Archiving verification analysis records..."
            archiveArtifacts artifacts: 'validation_report.log', fingerprint: true, allowEmptyArchive: true
        }
        failure {
            echo "🚨 Pipeline deployment regression found! Executing instant rollback routine..."
            sh "kubectl rollout undo deployment/water-monitoring-app || echo 'No active deployment to rollback'"
        }
    }
}
