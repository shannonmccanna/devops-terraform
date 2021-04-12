def projectId = "devops-capstone-309221"

pipeline {
   agent any

   stages {
        stage('Stage 1 - workspace and versions') {
                        
            steps {
                echo '****************************** Stage 1'
                sh 'echo $WORKSPACE'
                //sh 'docker --version'
                sh 'gcloud version'
                sh 'nodejs -v'
                sh 'npm -v'
            }
        }
        
        stage('Stage 2 - Source and Sonarqube') {
            steps {
                echo '****************************** Stage 2'
                dir("${env.WORKSPACE}/internal"){
                  echo 'Retrieving source from github' 
                    git branch: 'main',
                        url: 'https://github.com/shannonmccanna/devops-internal.git'
                    sh "ls -a"
                    echo 'install dependencies' 
                    sh 'npm install'
                    echo 'Run tests'
                    sh 'npm test'
                    echo 'Tests passed'
                    echo 'Running quality scan'                    
                }
                withSonarQubeEnv('sonarqube') {
                    script {
                        def scannerHome = tool 'sonarqube';
                        sh "${scannerHome}/bin/sonar-scanner \
                          -D sonar.login=admin \
                          -D sonar.password=Houston7213 \
                          -D sonar.projectKey=internal \
                          -D sonar.host.url=http://34.70.119.219:9000/"
                    }
                }
               // timeout(time: 1, unit: 'HOURS') {
            //        waitForQualityGate abortPipeline: true
              //  }
            }
        }
        
        stage('Stage 3 - Build internal image') {
            steps {
                echo '****************************** Stage 3'
                dir("${env.WORKSPACE}/internal"){
                    echo "build id = ${env.BUILD_ID}"
                    sh "gcloud builds submit -t gcr.io/${projectId}/internal-image:v2.${env.BUILD_ID} ."
                }
            }
        }
        stage('Stage 4 - Deploy internal image') {
            steps {
                echo '****************************** Stage 4'
                echo 'Connecting to the cluster'
                sh "gcloud container clusters get-credentials capstone-events-feed-cluster --zone us-central1-a --project ${projectId}"
                echo 'Updating the cluster image'
                echo "gcr.io/${projectId}/internal-image:2.${env.BUILD_ID}"
                sh "kubectl set image deployment/capstone-internal-events-feed-deployment capstone-internal-events-feed=gcr.io/${projectId}/internal-image:v2.${env.BUILD_ID} -n=capstone-events-feed --record"
            }
        }
        stage('Stage 5 - Get source and build external image') {
            steps {
                echo '****************************** Stage 5'
                dir("${env.WORKSPACE}/external"){
                    echo 'Retrieving source from github' 
                    git branch: 'main',
                        url: 'https://github.com/shannonmccanna/devops-external.git'
                    sh 'ls -a'
                    echo 'install dependencies' 
                    sh 'npm install'
                    echo "build id = ${env.BUILD_ID}"
                    sh "gcloud builds submit -t gcr.io/${projectId}/external-image:v2.${env.BUILD_ID} ."
                }
            }
        }
        stage('Stage 6 - Deploy External image') {
            steps {
                echo '****************************** Stage 6'
                echo 'Connecting to the cluster'
                sh "gcloud container clusters get-credentials capstone-events-feed-cluster --zone us-central1-a --project ${projectId}"
                echo 'Updating the cluster image'
                echo "gcr.io/${projectId}/external-image:2.${env.BUILD_ID}"
                sh "kubectl set image deployment/capstone-external-events-feed-deployment capstone-external-events-feed=gcr.io/${projectId}/external-image:v2.${env.BUILD_ID} -n=capstone-events-feed --record"
            }
        }
   }
}

