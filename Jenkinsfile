pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'vue3-app:${BUILD_ID}'  # 唯一化镜像标签
        NGINX_PORT = '80'                    # Nginx 监听端口
        DOCKER_REGISTRY = ''                  # 可选：私有镜像仓库地址
    }

    stages {
        stage('拉取代码') {
            steps {
                git 'https://github.com/gukaitest/test01.git', branch: 'main'
            }
        }

        stage('构建项目') {
            steps {
                nodejs('node 23.8.0') {
                    sh 'pnpm config set registry https://registry.npmmirror.com'
                    sh 'pnpm cache clean --force'
                    sh 'pnpm install'
                    sh 'pnpm run build'
                }
            }
        }

        stage('创建 Docker 镜像') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE} .'
            }
        }

        stage('推送镜像到仓库') { // 可选
            steps {
                if (DOCKER_REGISTRY) {
                    sh "docker tag ${DOCKER_IMAGE} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
                }
            }
        }

        stage('部署到本地服务器') {
            steps {
                script {
                    // 停止旧容器
                    sh "docker stop vue3-app-container || true && docker rm -f vue3-app-container || true"

                    // 拉取最新镜像（本地或私有仓库）
                    if (DOCKER_REGISTRY) {
                        sh "docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
                    } else {
                        sh "docker pull ${DOCKER_IMAGE}"
                    }

                    // 运行新容器
                    sh "docker run -d \
                        -p ${NGINX_PORT}:80 \  # Nginx 监听端口 -> 容器端口
                        --name vue3-app-container \
                        --restart always \
                        ${DOCKER_IMAGE}"
                }
            }
        }

        stage('验证部署') {
            steps {
                // 检查 Nginx 是否代理成功
                sh 'curl -I http://localhost:${NGINX_PORT}'  # 应返回 HTTP 200

                // 查看容器日志
                sh 'docker logs vue3-app-container'
            }
        }
    }

    post {
        always {
            // 清理本地镜像
            sh 'docker rmi -f ${DOCKER_IMAGE}'
        }
        success {
            echo '部署成功！'
        }
        failure {
            echo '部署失败，请检查容器日志：`docker logs vue3-app-container`'
        }
    }
}
