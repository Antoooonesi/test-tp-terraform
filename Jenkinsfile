pipeline {
    agent any
    options {
        // options
        ansiColor('xterm')
    }

    parameters {
        // Parameters
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'Destroy')
    }

    environment {
        // environment variables
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('iac:terraform plan') {
             when {
                expression { params.DESTROY == false }
            }
            steps {
                script {
                    sh '''
                        terraform init
                        terraform plan
                    '''
                }
            }
        }

        stage('confirm:deploy') {
            when {
                expression { params.DESTROY == false }
            }
            steps {
                input(id: 'confirm', message: """
                    You chose to deploy:
                    - branch: ${env.GIT_BRANCH}
                    Do you confirm the deployment?
                """)
            }
        }

        stage('confirm:destroy') {
            when {
                expression { params.DESTROY == true }
            }
            steps {
                input(id: 'confirm', message: """
                    You chose to destroy:
                    - branch: ${env.GIT_BRANCH}
                    Do you confirm the destroy?
                """)
            }
        }

        stage('iac:terraform plan deploy') {
            when {
                expression { !params.DESTROY == false }
            }
            steps {
                script {
                    sh '''
                        terraform plan
                    '''
                }
            }
        }
        stage('iac:terraform plan destroy') {
            when {
                expression { params.DESTROY == false }
            }
            steps {
                script {
                    sh '''
                        terraform plan -destroy
                    '''
                }
            }
        }

       stage('iac:terraform apply') {
        when {
                expression { params.DESTROY == false }
            }
            steps {
                script {
                    sh '''
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('iac:terraform destroy') {
            when {
                expression { params.DESTROY == true }
            }
            steps {
                script {
                    sh '''
                        terraform apply -destroy -auto-approve
                    '''
                }
            }
        }
    }

    post { 
        always { 
            cleanWs()
        }
    }
}

    