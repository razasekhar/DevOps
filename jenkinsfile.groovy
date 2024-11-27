pipeline {
    agent any

    stages {
        stage('clean') {
            steps {
               echo cleanWs()
            }
        }
            stage('Git'){
                steps{
                    git branch: 'main', credentialsId: '5e8a3906-a65b-4f3e-a05c-488d0cd90fdd', url: 'https://github.com/razasekhar/DevOps.git'
                
            }
        }
    }
}
