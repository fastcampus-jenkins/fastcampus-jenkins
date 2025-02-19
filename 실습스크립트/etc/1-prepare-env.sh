
docker run -it --name=openssh-server -e PUBLIC_KEY_FILE=/pubkey/pub.key -p 2222:2222 -v /var/run/docker.sock:/var/run/docker.sock  -v /Users/rentalhub/pubkey:/pubkey  -e USER_NAME=user  lscr.io/linuxserver/openssh-server:latest
apk add --update openjdk11 docker
ssh -i ~/pubkey/private.key -p 2222 user@localhost

# 키 생성
mkdir projects
cd projects
docker run --rm -it --entrypoint /keygen.sh linuxserver/openssh-server
vi ~/projects/key/private.key
vi ~/projects/key/public.key
chmod 400 ~/projects/key/private.key

docker network create projects

docker run -d --name=operation \
     -e PUBLIC_KEY_FILE=/key/public.key \
     -p 2222:2222 -p 80:80 \
     -v ~/projects/key/:/key \
     -e SUDO_ACCESS=true \
     -e USER_NAME=user  \
     --hostname=operation \
     --network=projects \
     lscr.io/linuxserver/openssh-server:latest

ssh -i ~/projects/key/private.key -p 2222 user@localhost
exit
touch test.txt
scp -i ~/projects/key/private.key -P 2222 test.txt user@localhost:/config/test.txt
ssh -i ~/projects/key/private.key -P 2222 ls -al /config/

# 필요한 어플리케이션 설치
docker exec operation apk add --update haproxy cronie docker git
docker exec operation bash -c 'crond; haproxy -D -f /etc/haproxy/haproxy.cfg'
docker run -d --name=server_1 \
     -e PUBLIC_KEY_FILE=/key/public.key \
     -p 12222:2222 -p 18080:8080 \
     -v /var/run/docker.sock:/var/run/docker.sock  \
     -v ~/projects/key:/key \
     -e SUDO_ACCESS=true \
     -e USER_NAME=user  \
     --hostname=server_1 \
     --network=projects \
     lscr.io/linuxserver/openssh-server:latest

ssh -i ~/projects/key/private.key -p 12222 user@localhost

docker exec server_1 apk add --update openjdk11 docker nginx python

docker run -d --name=server_2 \
     -e PUBLIC_KEY_FILE=/key/public.key \
     -p 22222:2222 -p 28080:8080 \
     -v /var/run/docker.sock:/var/run/docker.sock  \
     -v ~/projects/key:/key \
     -e SUDO_ACCESS=true \
     -e USER_NAME=user  \
     --hostname=server_2 \
     --network=projects \
     lscr.io/linuxserver/openssh-server:latest

docker exec server_2 apk add --update openjdk11 docker nginx python
