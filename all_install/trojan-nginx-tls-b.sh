#! /bin/bash
# Author: Jeannie
#######color code########
RED="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"
green() {
  echo -e "\033[32m\033[01m$1\033[0m"
}
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH" >>~/.bashrc
source ~/.bashrc
echo "先睡一会儿……"
sleep 3
isRoot() {
  if [[ "$EUID" -ne 0 ]]; then
    echo "false"
  else
    echo "true"
  fi
}
init_release() {
  if [[ -f /etc/redhat-release ]]; then
    release="centos"
  elif cat /etc/issue | grep -q -E -i "debian"; then
    release="debian"
  elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  elif cat /proc/version | grep -q -E -i "debian"; then
    release="debian"
  elif cat /proc/version | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  fi
  if [[ $release == "ubuntu" || $release == "debian" ]]; then
    PM='apt'
  elif [[ $release == "centos" ]]; then
    PM='yum'
  else
    exit 1
  fi
  # PM='apt'
}
tools_install() {
  init_release
  if [ $PM = 'apt' ]; then
    apt-get update
    sleep 2
    apt-get install -y dnsutils wget unzip zip curl tar git nginx qrencode
    sleep 2
    apt-get install -y certbot
    sleep 2
    apt-get install -y cron
    nginx -s stop
  elif [ $PM = 'yum' ]; then
    yum update -y
    yum -y install bind-utils wget unzip zip curl tar git nginx crontabs libpng libpng-devel qrencode
    sleep 2
    yum install -y epel-release
    sleep 3
    yum install -y certbot
  fi
}
web_get() {
  mkdir /var/www
  echo -e "下面提供了15个不同的伪装网站模板，按对应的数字进行安装，安装之前可以查看网站demo:
  ${GREEN}1. https://templated.co/intensify
  ${GREEN}2. https://templated.co/binary
  ${GREEN}3. https://templated.co/retrospect
  ${GREEN}4. https://templated.co/spatial
  ${GREEN}5. https://templated.co/monochromed
  ${GREEN}6. https://templated.co/transit
  ${GREEN}7. https://templated.co/interphase
  ${GREEN}8. https://templated.co/ion
  ${GREEN}9. https://templated.co/solarize
  ${GREEN}10. https://templated.co/phaseshift
  ${GREEN}11. https://templated.co/horizons
  ${GREEN}12. https://templated.co/grassygrass
  ${GREEN}13. https://templated.co/breadth
  ${GREEN}14. https://templated.co/undeviating
  ${GREEN}15. https://templated.co/lorikeet${NO_COLOR}
  "
  read -p "您输入你要安装的网站的数字:" aNum
  case $aNum in
  1)
    wget -O web.zip --no-check-certificate https://templated.co/intensify/download
    ;;
  2)
    wget -O web.zip --no-check-certificate https://templated.co/binary/download
    ;;
  3)
    wget -O web.zip --no-check-certificate https://templated.co/retrospect/download
    ;;
  4)
    wget -O web.zip --no-check-certificate https://templated.co/spatial/download
    ;;
  5)
    wget -O web.zip --no-check-certificate https://templated.co/monochromed/download
    ;;
  6)
    wget -O web.zip --no-check-certificate https://templated.co/transit/download
    ;;
  7)
    wget -O web.zip --no-check-certificate https://templated.co/interphase/download
    ;;
  8)
    wget -O web.zip --no-check-certificate https://templated.co/ion/download
    ;;
  9)
    wget -O web.zip --no-check-certificate https://templated.co/solarize/download
    ;;
  10)
    wget -O web.zip --no-check-certificate https://templated.co/phaseshift/download
    ;;
  11)
    wget -O web.zip --no-check-certificate https://templated.co/horizons/download
    ;;
  12)
    wget -O web.zip --no-check-certificate https://templated.co/grassygrass/download
    ;;
  13)
    wget -O web.zip --no-check-certificate https://templated.co/breadth/download
    ;;
  14)
    wget -O web.zip --no-check-certificate https://templated.co/undeviating/download
    ;;
  15)
    wget -O web.zip --no-check-certificate https://templated.co/lorikeet/download
    ;;
  *)
    wget -O web.zip --no-check-certificate https://templated.co/intensify/download
    ;;
  esac
  unzip -o -d /var/www web.zip
}
nginx_conf() {
  green "=========================================="
  green "       开始申请证书"
  green "=========================================="
  read -p "请输入您的域名(注意：如果你的域名是使用 Cloudflare 解析的，请在Status 那里点一下那图标，让它变灰):" domainname
  real_addr=$(ping ${domainname} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
  local_addr=$(curl -4 ip.sb)
  while [ "$real_addr" != "$local_addr" ]; do
    read -p "本机ip和绑定域名的IP不一致，请检查域名是否解析成功,并重新输入域名:" domainname
    real_addr=$(ping ${domainname} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
    local_addr=$(curl -4 ip.sb)
    if [ "$real_addr" != "$local_addr" ]; then
      local_addr=$(curl ipv4.icanhazip.com)
    fi
    if [ "$real_addr" != "$local_addr" ]; then
      local_addr=$(curl -4 ifconfig.me)
    fi
  done
  echo "$domainname" 2>&1 | tee /etc/domainname
  read -p "请输入您的邮箱：" emailname
  read -p "您输入的邮箱正确吗? [y/n]?" answer
  while [ "$answer" != "y" ]; do
    read -p "请重新输入您的邮箱：" emailname
    read -p "您输入的邮箱正确吗? [y/n]?" answer
  done
  certbot certonly --standalone -n --agree-tos --email $emailname -d $domainname
  curl -s -o /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/JeannieStudio/jeannie/master/default.conf
  sed -i "s/127.0.0.1/$domainname/g" /etc/nginx/conf.d/default.conf
  sleep 1
  sed -i "s/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g" /etc/nginx/nginx.conf
  sleep 1
}
trojan_install() {
  green "=========================================="
  green "       开始安装Trojan"
  green "=========================================="
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
}
trojan_conf() {
  read -p "请输入您的trojan密码：" password
  fl="no"
  while [[ $fl = "no" ]]; do
      read -p "密码只能是字母和数字的组合：" password
      for ((i=0;$i<${#password};i++));
      do
          str=${password:$i:1};
          case "$str" in
          [a-z]|[A-Z]|[0-9])fl="yes"
              ;;
             *)echo "密码中含非法字符"
               fl="no"
                break
              ;;
          esac
      done
  done
  while [ "${password}" = "" ]; do
    read -p "密码不能为空，请重新输入：" password
  done
  sed -i "8c \"$password\"," /usr/local/etc/trojan/config.json
  cd /etc/letsencrypt/live/$domainname
  \cp fullchain.pem /usr/local/etc/trojan 2>&1 | tee /usr/local/etc/log
  \cp privkey.pem /usr/local/etc/trojan 2>&1 | tee /usr/local/etc/log
  sed -i "13c \"cert\":\"/usr/local/etc/trojan/fullchain.pem\"," /usr/local/etc/trojan/config.json
  sed -i "14c \"key\": \"/usr/local/etc/trojan/privkey.pem\"," /usr/local/etc/trojan/config.json
}
left_second() {
  seconds_left=30
  while [ $seconds_left -gt 0 ]; do
    echo -n $seconds_left
    sleep 1
    seconds_left=$(($seconds_left - 1))
    echo -ne "\r     \r"
  done
}
CA_exist() {
  grep "cp: cannot stat" /usr/local/etc/log >/dev/null
  if [ $? -eq 0 ]; then
    FLAG="YES"
  else
    FLAG="NO"
  fi
}
check_CA() {
  CA_exist
  if [ $FLAG = "NO" ]; then
    end_time=$(echo | openssl s_client -servername $domainname -connect $domainname:443 2>/dev/null | openssl x509 -noout -dates | grep 'After' | awk -F '=' '{print $2}' | awk -F ' +' '{print $1,$2,$4 }')
    #while [ "${end_time}" = "" ]; do
    #  end_time=$(echo | openssl s_client -servername $domainname -connect $domainname:443 2>/dev/null | openssl x509 -noout -dates | grep 'After' | awk -F '=' '{print $2}' | awk -F ' +' '{print $1,$2,$4 }')
    #done
    end_times=$(date +%s -d "$end_time")
    now_time=$(date +%s -d "$(date | awk -F ' +' '{print $2,$3,$6}')")
    RST=$(($((end_times - now_time)) / (60 * 60 * 24)))
  fi
}
add_CA() {
  init_release
  CA_exist
  if [ $FLAG = "NO" ]; then
    curl -s -o /etc/RST.sh https://raw.githubusercontent.com/JeannieStudio/jeannie/master/RST.sh
    chmod +x /etc/RST.sh
    if [ $PM = 'apt' ]; then
      cron_job="30 4 * * * /etc/RST.sh"
      (
        crontab -l | grep -v "$cron_job"
        echo "$cron_job"
      ) | crontab -
      service cron restart
    elif [ $PM = 'yum' ]; then
      echo "SHELL=/bin/bash
30 4 * * * /etc/RST.sh" >/var/spool/cron/root
      service crond reload
      service crond restart
    fi
  fi
}
mgr() {
  if [ -f "/etc/mgr.sh" ]; then
    rm -f /etc/mgr.sh
  fi
  while [ ! -f "/etc/mgr.sh" ]; do
    curl -s -o /etc/mgr.sh https://raw.githubusercontent.com/JeannieStudio/all_install/master/mgr.sh
  done
  chmod +x /etc/mgr.sh
}
info() {
  vps=trojan
  echo "$password" >>/usr/local/etc/trojan/trojan_info
  echo "$domainname" >>/usr/local/etc/trojan/trojan_info
  echo "$vps" >>/usr/local/etc/trojan/trojan_info
  code="trojan://${password}@${domainname}:443"
  qrencode -o /var/www/${password}.png -s 8 "${code}"
  wget --no-check-certificate -O /var/www/trojan_tmpl.html https://raw.githubusercontent.com/JeannieStudio/all_install/master/trojan_tmpl.html
  chmod +x /var/www/trojan_tmpl.html
  eval "cat <<EOF
      $(</var/www/trojan_tmpl.html)
      EOF
      " >/var/www/${password}.html
}
main() {
  isRoot=$(isRoot)
  if [[ "${isRoot}" != "true" ]]; then
    echo -e "${RED}error:${NO_COLOR}Please run this script as as root"
    exit 1
  else
    tools_install
    web_get
    nginx_conf
    nginx
    systemctl enable nginx.service
    trojan_install
    echo "睡一会儿……"
    sleep 5
    trojan_conf
    systemctl start trojan
    systemctl enable trojan
    CA_exist
    check_CA
    add_CA
    mgr
    info
    if [ $FLAG = "YES" ]; then
      echo -e "
$RED============================================================
$RED    很遗憾，Trojan安装和配置失败
$RED ===========================================================
${RED}由于证书申请失败，无法科学上网，请重装或更换一个域名重新安装， 详情：https://letsencrypt.org/docs/rate-limits/
进一步验证证书申请情况，参考：https://www.ssllabs.com/ssltest/ $NO_COLOR" 2>&1 | tee info
    elif [ $FLAG = "NO" ]; then
      echo -e "
${GREEN}  ==================================================
${GREEN}       恭喜你，Trojan安装和配置成功
${GREEN} ===================================================
详情：https://${domainname}/${password}.html $NO_COLOR " 2>&1 | tee info
    fi
    touch /etc/motd
    cat info >/etc/motd
  fi
}
main
