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
                        url: 'https://github.com/shannonmccanna/devops_internal.git'
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
                          -D sonar.password=admin \
                          -D sonar.projectKey=internal \
                          -D sonar.host.url=http://34.70.119.219:9000/"
                    }
                }
               // timeout(time: 1, unit: 'HOURS') {
               //     waitForQualityGate abortPipeline: true
                //}
            }
        }
        
        stage('Stage 3 - Build internal') {
            steps {
                echo '****************************** Stage 3'
                dir("${env.WORKSPACE}/internal"){
                    echo "build id = ${env.BUILD_ID}"
                    sh "gcloud builds submit -t gcr.io/${projectId}/internal-image:v2.${env.BUILD_ID} ."
                }
            }
        }
        stage('Stage 4 - Deploy image') {
            steps {
                echo 'Get cluster credentials'
                sh "gcloud container clusters get-credentials capstone-events-feed-cluster --zone us-central1-a --project ${projectId}"
                echo 'Update the image'
                echo "gcr.io/${projectId}/internal:2.${env.BUILD_ID}"
                sh "kubectl set image deployment/capstone-external-events-feed-deployment demo-internal-events-feed=gcr.io/${projectId}/internal-image:v2.${env.BUILD_ID} -n demo-events-feed --record"
            }
        }

   }
}

