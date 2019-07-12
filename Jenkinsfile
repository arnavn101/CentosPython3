pipeline {

	agent { 
		docker { 
			image '13065729n/centos-python3:latest' 
			args '-u root:root -v $HOME/workspace'
		} 
	}

	triggers {
		cron('*/5 * * * *')
	}

	stages {
		stage('build') {
			steps {
				sh 'pip3.6 install pfurl' 
			}
		}

		stage('test') {
			steps {
				sh 'pfurl-h'
			}

			post {
				failure {
					load "env.groovy"
					echo "${env.DB_URL}"
					emailext attachmentsPattern: 'moc-health-check/error.log', body: "${env.DB_URL}", subject: 'test', to: '13065729n@gmail.com'
				}
			}
		}
	}
}
