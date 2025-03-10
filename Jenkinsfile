pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'vue3-app:latest'
        PATH = "${env.PATH}:/usr/bin"
    }

    stages {
        stage('拉取代码') {
            steps {
                git 'https://github.com/gukaitest/test01.git'
            }
        }

        stage('构建项目') {
            steps {
                nodejs('node 23.8.0') {
                    sh 'rm -rf node_modules' // 删除 node_modules 目录
                    sh 'rm -f package-lock.json pnpm-lock.yaml' // 删除锁文件
                    // 安装 pnpm
                    sh 'pnpm config set registry https://registry.npmmirror.com' // 设置镜像源
                    sh 'npm install -g pnpm'
                    sh 'pnpm cache clean'
                    sh 'pnpm store prune'
                    sh 'echo $PATH'
                    sh 'node -v'
                    sh 'pnpm -v'
                    sh 'echo "开始安装依赖..."'
                    sh 'pnpm install'
                    sh 'echo "依赖安装完成，开始构建项目..."'
                    sh 'pnpm run build'
                    sh 'echo "项目构建完成。"'
                }
            }
        }

        stage('创建 Docker 镜像') {
            steps {
                sh 'pwd'          // 输出当前工作区绝对路径
                sh 'ls -l'         // 列出所有文件，确认是否存在 Dockerfile
                sh 'find . -name Dockerfile'  // 搜索整个目录树1
                sh 'docker build -t vue3-app:latest .'

            }
        }

        stage('部署到服务器') {
            steps {
                script {
                    // 停止并删除旧容器
                    sh "docker stop vue3-app-container || true && docker rm vue3-app-container || true"
                    // 运行新容器
                    sh "docker run -d -p 8080:80 -p 443:80 --name vue3-app-container ${DOCKER_IMAGE}"
                }
            }
        }

        stage('检查 Nginx 配置') {
            steps {
                echo '请检查 Nginx 配置是否正确指向 8080 端口。'
            }
        }
    }

    post {
        success {
            echo '部署成功！'
        }
        failure {
            echo '部署失败，请检查日志。'
        }
    }
}
