#!/bin/bash
#
# script que baixa fontes do asterisk, zaptel, add-ons e libpri
# e instala todas as dependencias possiveis no debian e prepara o build
#
# isso eh pra uso pessoal pra ganhar tempo, nao tem garantia de funcionamento
# nem de que nao ira estragar o seu sistema. use por propria conta e risco
#
# caio begotti <caio@ueberalles.net>
# Thu Jun 21 08:33:57 BRT 2007

# versao pra baixar dos componentes
# pode ser 1.4 ou trunk, por exemplo
base_version="${1}"

# repositorio subversion principal da digium
ast_svn=http://svn.digium.com/svn

# comando minimo do apt-get pra instalar pacotes
apt="$(which apt-get) --force-yes -y"

# necessario pro m-a depois
alias apt-get="${apt}"

# comando minimo do subversion pra baixar os fontes
svn="$(which svn)"

function func_log()
{
	echo -e "${1}"
}

function func_install_pack()
{
	# prepara o ambiente pra nao fazer perguntas
	debconf -f non-interactive -p critical

	# pega a lista de pacotes do fim do script e instala todos
	sed "1,/^# dpkg/d" ${0} | dpkg --set-selections
	${apt} dselect-upgrade -u

	# prepara o kernel pro zaptel
	module-assistant -t -f -i prepare
}

function func_asterisk_fetch()
{
	mkdir -p ./${base_version} && cd ./${base_version}

	for component in zaptel libpri asterisk asterisk-addonsas
	do
		# atualiza a URL completa pra cada item
		source_path=${ast_svn}/${component}/${base_version}

		# baixa o codigo fonte de cada um dos componentes
		${svn} checkout ${source_path} ./${component}
		cd ./${component}

		if [ ! ${component} == "libpri" ]
		then
			# default do debian
			./configure --prefix=/usr
		fi

		# compila e instala o minimo pra economizar tempo depois
		make && make install

		# retorna ao nivel anterior
		cd -
	done
}

# checagens minimas do script
if [ -z "${base_version}" ]
then
	func_log "Versao base dos fontes NAO foi especificada.\n"

	func_log "Voce precisa passar como parametro pro script uma versao"
	func_log "disponivel do Asterisk e seus componentes (1.2, 1.4, 1.6 ou trunk).\n"

	exit 1
else
	if [ ${base_version} == "trunk" ]
	then
		base_version=trunk
	else
		base_version=branches/${base_version}
	fi

	# o path do asterisk eh somente para teste da URL
	source_path=${ast_svn}/asterisk/${base_version}
	${svn} list ${source_path} > /dev/null || ( func_log "XXXXXXXX"; exit 1;)
fi

func_install_pack
func_asterisk_fetch

exit 0

# dpkg: NAO EDITAR NEM REMOVER ESSA LINHA OU NENHUMA ABAIXO

python-xml					install
acpid						install
adduser						install
apache-common					install
apache2-common					install
apache2-mpm-prefork				install
apache2-utils					install
apt						install
apt-file					install
apt-utils					install
aptitude					install
at						install
autotools-dev					install
base-files					install
base-passwd					install
bash						install
binutils					install
bison						install
bsdmainutils					install
bsdutils					install
build-essential					install
busybox						install
bzip2						install
ca-certificates					install
cdbs						install
comerr-dev					install
console-common					install
console-data					install
console-tools					install
coreutils					install
cpio						install
cpp						install
cpp-4.1						install
cron						install
debconf						install
debconf-i18n					install
debhelper					install
debianutils					install
defoma						install
devscripts					install
dh-make						install
dhcp-client					install
diff						install
dmidecode					install
docbook-xsl					install
doxygen						install
dpatch						install
dpkg						install
dpkg-dev					install
dselect						install
e2fslibs					install
e2fsprogs					install
ed						install
eject						install
esound-common					install
exim4						install
exim4-base					install
exim4-config					install
exim4-daemon-light				install
fakeroot					install
file						install
findutils					install
fontconfig					install
fontconfig-config				install
freetds-dev					install
g++						install
g++-4.1						install
gcc						install
gcc-4.0-base					install
gcc-4.1						install
gcc-4.1-base					install
gdb						install
gettext						install
gettext-base					install
gnupg						install
graphviz					install
grep						install
groff-base					install
grub						install
gsfonts						install
gzip						install
hostname					install
html2text					install
hwinfo						install
ifupdown					install
info						install
initramfs-tools					install
initscripts					install
installation-report				install
intltool-debian					install
iptables					install
iputils-ping					install
klibc-utils					install
klogd						install
laptop-detect					install
less						install
liba52-0.7.4					install
libaa1						install
libaa1-dev					install
libacl1						install
libapache-dbi-perl				install
libapache-mod-perl				install
libapache2-mod-php5				install
libapache2-mod-proxy-html			install
libapr0						install
libapt-pkg-perl					install
libartsc0					install
libartsc0-dev					install
libasound2					install
libasound2-dev					install
libasterisk-perl				install
libattr1					install
libaudio-dev					install
libaudio2					install
libaudiofile-dev				install
libaudiofile0					install
libblkid1					install
libbz2-1.0					install
libc6						install
libc6-dev					install
libcap-dev					install
libcap1						install
libcomerr2					install
libconfig-inifiles-perl				install
libconfigfile-perl				install
libconsole					install
libct3						install
libcurl3					install
libcurl3-dev					install
libcurl3-openssl-dev				install
libdb4.2					install
libdb4.3					install
libdb4.4					install
libdbi-perl					install
libdbus-1-3					install
libdevel-symdump-perl				install
libdevmapper1.02				install
libdirectfb-0.9-25				install
libdirectfb-dev					install
libdirectfb-extra				install
libdrm2						install
libedit2					install
libesd0						install
libesd0-dev					install
libexpat1					install
libexpat1-dev					install
libfontconfig1					install
libfreetype6					install
libfreetype6-dev				install
libgcc1						install
libgcrypt11					install
libgcrypt11-dev					install
libgdbm3					install
libgl1-mesa-dev					install
libgl1-mesa-dri					install
libgl1-mesa-glx					install
libglib2.0-0					install
libglib2.0-dev					install
libglu1-mesa					install
libglu1-mesa-dev				install
libglu1-xorg-dev				install
libgnutls-dev					install
libgnutls13					install
libgpg-error-dev				install
libgpg-error0					install
libgpmg1					install
libgsm1						install
libgsm1-dev					install
libhal1						install
libhd13						install
libhtml-parser-perl				install
libhtml-tagset-perl				install
libhtml-tree-perl				install
libice-dev					install
libice6						install
libident					install
libidn11					install
libidn11-dev					install
libiksemel-dev					install
libiksemel3					install
libjpeg62					install
libjpeg62-dev					install
libkadm55					install
libklibc					install
libkrb5-dev					install
libkrb53					install
liblcms1					install
libldap-2.3-0					install
libldap2					install
libldap2-dev					install
liblocale-gettext-perl				install
liblockfile1					install
libltdl3					install
libltdl3-dev					install
liblzo-dev					install
liblzo1						install
liblzo2-2					install
libmad0						install
libmagic1					install
libmng1						install
libmpeg3-1					install
libmpeg3-dev					install
libncurses5					install
libncurses5-dev					install
libncursesw5					install
libneon25					install
libnet-daemon-perl				install
libnet-telnet-perl				install
libnewt-dev					install
libnewt0.52					install
libodbcinstq1c2					install
libogg-dev					install
libogg0						install
libopencdk8					install
libopencdk8-dev					install
libopenh323-1.18.0				install
libopenh323-dev					install
libpam-modules					install
libpam-runtime					install
libpam0g					install
libpcre3					install
libperl5.8					install
libplrpc-perl					install
libpng12-0					install
libpng12-dev					install
libpopt-dev					install
libpopt0					install
libpq-dev					install
libpq3						install
libpq4						install
libpri-dev					install
libpri1.2					install
libpt-1.10.0					install
libpt-dev					install
libqt3-mt					install
libradiusclient-ng-dev				install
libradiusclient-ng2				install
libreadline5					install
libreadline5-dev				install
libsasl2					install
libsasl2-dev					install
libsdl1.2-dev					install
libsdl1.2debian					install
libsdl1.2debian-alsa				install
libselinux1					install
libsensors-dev					install
libsensors3					install
libsepol1					install
libsigc++-1.2-5c2				install
libsigc++-2.0-0c2a				install
libslang2					install
libslang2-dev					install
libsm-dev					install
libsm6						install
libsnmp-base					install
libsnmp-perl					install
libsnmp9					install
libsnmp9-dev					install
libspandsp-dev					install
libspandsp1					install
libspeex-dev					install
libspeex1					install
libsqlite0					install
libsqlite0-dev					install
libss2						install
libssl-dev					install
libssl0.9.8					install
libssp0						install
libstdc++6					install
libstdc++6-4.1-dev				install
libsvga1					install
libsvga1-dev					install
libsvn-core-perl				install
libsvn0						install
libsybdb5					install
libsysfs2					install
libtasn1-3					install
libtasn1-3-bin					install
libtasn1-3-dev					install
libtext-charwidth-perl				install
libtext-iconv-perl				install
libtext-wrapi18n-perl				install
libtiff4					install
libtiff4-dev					install
libtiffxx0c2					install
libtonezone-dev					install
libtonezone1					install
libtool						install
liburi-perl					install
libusb-0.1-4					install
libusb-dev					install
libuuid1					install
libvolume-id0					install
libvorbis-dev					install
libvorbis0a					install
libvorbisenc2					install
libvorbisfile3					install
libwrap0					install
libwrap0-dev					install
libwww-perl					install
libx11-6					install
libx11-data					install
libx11-dev					install
libxau-dev					install
libxau6						install
libxaw7						install
libxcursor1					install
libxdmcp-dev					install
libxdmcp6					install
libxext-dev					install
libxext6					install
libxfixes3					install
libxft2						install
libxi6						install
libxinerama1					install
libxml2						install
libxml2-dev					install
libxmu6						install
libxpm4						install
libxrandr2					install
libxrender1					install
libxslt1.1					install
libxt-dev					install
libxt6						install
libxxf86vm1					install
libzap-dev					install
libzap1						install
linux-headers-2.6.17-2				install
linux-headers-2.6.17-2-686			install
linux-image-2.6-686				install
linux-image-2.6.17-2-686			install
linux-kbuild-2.6.17				install
linux-kernel-headers				install
locales						install
localization-config				install
login						install
logrotate					install
lsb-base					install
lsof						install
lynx						install
m4						install
mailx						install
make						install
makedev						install
man-db						install
manpages					install
mawk						install
mesa-common-dev					install
mime-support					install
mktemp						install
module-assistant				install
module-init-tools				install
modutils					install
mount						install
nano						install
ncurses-base					install
ncurses-bin					install
net-tools					install
netbase						install
netcat						install
nmap						install
odbc-postgresql					install
odbcinst1debian1				install
openbsd-inetd					install
openssh-client					install
openssh-server					install
openssl						install
passwd						install
patch						install
perl						install
perl-base					install
perl-modules					install
php5-cli					install
php5-common					install
php5-pgsql					install
pkg-config					install
po-debconf					install
postgresql					install
postgresql-8.1					install
postgresql-client				install
postgresql-client-8.1				install
postgresql-client-common			install
postgresql-common				install
postgresql-contrib				install
postgresql-contrib-8.1				install
postgresql-dev					install
postgresql-plperl-8.1				install
procps						install
psmisc						install
python						install
python-minimal					install
python-subversion				install
python2.4					install
python2.4-minimal				install
rcs						install
readline-common					install
sed						install
sgml-base					install
sox						install
ssh						install
ssl-cert					install
stow						install
strace						install
subversion					install
subversion-tools				install
sudo						install
svgalibg1					install
svn-buildpackage				install
sysklogd					install
sysv-rc						install
sysvinit					install
tar						install
tasksel						install
tasksel-data					install
tcl8.4						install
tcpd						install
tk8.4						install
traceroute					install
tree						install
ttf-dejavu					install
tzdata						install
ucf						install
udev						install
unixodbc					install
unixodbc-dev					install
usbutils					install
util-linux					install
vim						install
vim-common					install
vim-runtime					install
vim-tiny					install
wget						install
whiptail					install
x11-common					install
x11proto-core-dev				install
x11proto-input-dev				install
x11proto-kb-dev					install
x11proto-xext-dev				install
xml-core					install
xsltproc					install
xtrans-dev					install
zlib1g						install
zlib1g-dev					install
