# 基础镜像，使用 Node.js 23.8.0（这里假设你之前用的版本就是构建所需的）
FROM node:23.8.0

# 设置工作目录
WORKDIR /app

# 复制项目文件，先复制 package.json 和 pnpm-lock.yaml（如果有）以利用缓存
COPY package*.json pnpm-lock.yaml* ./

# 安装 pnpm
RUN npm install -g pnpm

# 设置镜像源
RUN pnpm config set registry https://registry.npmmirror.com

# 安装依赖
RUN pnpm install

# 复制项目所有文件
COPY . .

# 构建项目
RUN pnpm run build

# 使用 Nginx 作为生产环境服务器
FROM nginx:stable-alpine

# 移除 Nginx 默认配置
RUN rm /etc/nginx/conf.d/default.conf

# 复制自定义的 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/

# 将之前构建好的 Vue 项目静态文件复制到 Nginx 的默认静态文件目录
COPY --from=0 /app/dist /usr/share/nginx/html

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]