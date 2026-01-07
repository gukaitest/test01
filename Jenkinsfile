pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'vue3-app:latest'
        PATH = "${env.PATH}:/usr/bin"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/gukaitest/test01.git'
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

        stage('Build Docker Image') {
            steps {
                script {
                    // 使用 Docker Pipeline 插件语法
                    sh 'echo "构建镜像..."'
                    sh 'pwd'          // 输出当前工作区绝对路径
                    sh 'ls -l'         // 列出所有文件，确认是否存在 Dockerfile
                    sh 'find . -name Dockerfile'  // 搜索整个目录树
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Cleanup Old Container') {
            steps {
                script {
                    sh 'docker stop vue3-app-container || true'
                    sh 'docker rm vue3-app-container || true'
                }
            }
        }

        stage('Run Container') {
            steps {
                script {
                    // 运行新容器
                    sh "docker run -d -p 8086:80 --name vue3-app-container ${DOCKER_IMAGE}"
                }
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
        always {
            // 清理旧镜像（可选，根据需要启用）
            // sh 'docker system prune -af'
            echo 'Pipeline 执行完成'
        }
    }
}
