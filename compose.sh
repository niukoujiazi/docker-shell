#!/bin/sh
re_docker() {
        sudo systemctl enable docker
        sudo systemctl restart docker
        if [ ! $? -ne 0 ]
        then
                sudo systemctl reset-failed docker.service
        fi
}
install_compose() {
        echo "修改配置"
        if [ ! -d /etc/docker ]; then mkdir /etc/docker ; fi
        if [ ! -d /etc/default/ ]; then mkdir /etc/default/; fi
        echo "DOCKER_OPTS=\"--registry-mirror=https://registry.docker-cn.com --insecure-registries=47.107.136.215:5000a\"" >> /etc/default/docker
        echo -e "{\n    \"registry-mirror\": [\"https://registry.docker-cn.com\"],\n    \"insecure-registries\": [\"47.107.136.215:5000\"]\n} "> /etc/docker/daemon.json
	echo "重启docker"
        re_docker
	echo "拉取镜像"
        sudo docker pull 47.107.136.215:5000/jyt:21.2
	echo "运行并拷贝镜像中内容"
        sudo docker run -dit --name jyt 47.107.136.215:5000/jyt:21.2
        sudo docker cp jyt:/jytconf/ ./
	echo "二进制安装docker-compsoe"
        cat ./jytconf/compose.sh > /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
	echo "修改django hosts"
        echo -e "Please enter Django's ALLOWED_HOSTS_ENV \nThe format is ‘0.0.0.0’:"
        read SERVER_HOSTS
        con="DB_HOSTS_ENV=db\nREDIS_HOSTS_ENV=redis\nALLOWED_HOSTS_ENV=$SERVER_HOSTS"
        echo -e $con > ./jytconf/jyt.env
	echo "删除中间容器"
        sudo docker container stop jyt
        sudo docker container rm jyt
        sudo docker network create -d bridge jyt-net 2> /dev/null
	echo "完成安装"
	exit 0
}
install_compose

