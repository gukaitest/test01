# 使用 Nginx 作为生产环境服务器
# 如果国内镜像无法访问，可以尝试：
# hub-mirror.c.163.com/library/nginx:alpine (网易镜像)
# mirror.baidubce.com/library/nginx:alpine (百度云镜像)
# 或者直接使用官方镜像: nginx:alpine
FROM nginx:alpine

# 删除默认配置
RUN rm /etc/nginx/conf.d/default.conf

# 复制自定义 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/

# 复制本地构建的静态文件
COPY dist /usr/share/nginx/html

# 暴露 80 端口
EXPOSE 80
