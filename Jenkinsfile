// SPDX-License-Identifier: LicenseRef-Procept
// SPDX-FileCopyrightText: Copyright © 2023 Procept Pty Ltd. All rights reserved.
//
// Automated Build pipeline declaration for makeshift.
//
pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
            // REVISIT: Makeshift doesn't have ARCH definitions for arm64.
            label "amd64 && docker"
        }
    }
    environment {
                    VERSION = """${sh(script: 'make -s +val[VERSION]',
                                        returnStdout: true).trim()}"""

                    PROJECT = """${sh(script: 'make -s +val[PROJECT]',
                                        returnStdout: true).trim()}"""
                }
    stages {
        stage('Build Info') {
            steps {
                echo "Project: ${PROJECT} Version: ${VERSION}"
            }
        }

        stage('Format Check') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh 'make tidy'
                    sh 'git diff --color --exit-code'
                }
            }
        }

        stage('Lint') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh 'make lint'
                }
            }
        }

        stage('Build') {
            steps {
                sh 'make'
            } 
        }
        stage('Test') {
            steps {
                // REVISIT: Make the tests work.
                echo 'make test-xml'
            }
        }
        stage('Package') {
            steps {
                sh 'make deb'
            }
        }
        stage ('Archive') {
            steps {
                archiveArtifacts artifacts: "*.deb"
            }
        }
        stage('Publish') {
            when {
                tag 'v*'
            }
            environment {
                NEXUS_REPO_URL = "http://sw.procept.com.au/store/repository/apt-procept/"
            }
            steps {
                withCredentials([usernameColonPassword(credentialsId: 'NEXUS_REPO_CREDENTIALS', variable: 'USERPASS')]) {
                    sh """
                    set -xe
                    for file in ./*.deb; do
                        curl -f -u "\$USERPASS" -H "Content-Type: multipart/form-data" --data-binary "@\$file" "${NEXUS_REPO_URL}";
                    done
                    """
                }
            }
        }
    }
}
