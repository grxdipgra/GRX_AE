#!/bin/bash
################################################################
# Nombre del script : prepara.sh
# Descripcion : Crea un instalador de GrX - AE
# Creado por Alberto Avidad
clear
echo "###############################################################################"
echo "# Nombre del script : prepara.sh                                              #"
echo "# Descripcion : Crea un instalador de xrdp, java, weboffice, etoken, libre-   #"
echo "#               office, autofirma, certificados FNMT, DNI...                  #"
echo "#               sobre ubuntu mate, server o raspbian                          #"
echo "#                                                                             #"
echo "# Creado por $(tput bold) $(tput setab 6)Alberto Avidad Fernandez$(tput sgr 0)  $(tput bold)    Oficina de Software Libre $(tput setaf 2)OSL $(tput sgr 0)    #"
echo "#                                                                             #"
echo "###############################################################################"

trap 'limpia' ERR SIGHUP SIGINT SIGTERM
function limpia {
	echo "Instalación interrumpida"
	echo "$(tput sgr 0)"
	exit 1
}

if [ "$1" == "grx-desktop" ] || [ "$1" == "grx-server" ] || [ "$1" == "grx-rasp" ] || [ "$1" == "grx-mate-serv" ]
then 
	echo ""
	echo "Creando el instalador para $(tput bold) $(tput setaf 3)$1$(tput sgr 0)"
	cd GRX-AE
	tar -cvf xrdp_tar.tar xrdp_tar/ &> /dev/null
	echo "creando ejecutable"
	cat $1.sh xrdp_tar.tar > instalador.sh	
	chmod 755 instalador.sh	
	mv instalador.sh ..
	rm xrdp_tar.tar
	cd ..
	echo "$(tput sgr 0)"
	echo "$(tput bold)Enhorabuena!!"
	echo "$(tput sgr 0)El instalador para $1 ha sido creado en "
        echo ""
        echo "   $(tput bold) $(pwd)$(tput setaf 2)/instalador.sh $(tput sgr 0)"
	echo ""
	echo "Copia el instalador en tu distro cambia los permisos a 755 y ejecútala."
        echo ""
	exit 0
fi

echo "#                                                                             #"
echo "# Podemos crear 4 tipos de instalador:(en esta versión solo la de grx-server) #"
echo "#                                                                             #"
echo "# $(tput bold)$(tput setaf 2)./prepara.sh grx-servidor$(tput sgr 0) crea un instalador para ubuntu-server 16.04       #"
#echo "# $(tput bold)$(tput setaf 2)./prepara.sh grx-desktopr$(tput sgr 0) crea un instalador para ubuntu mate 16.04            #"
#echo "# $(tput bold)$(tput setaf 2)./prepara.sh grx-rasp crea un instalador para una distro ubuntu-mate-raspbian 16.04"
#echo "# $(tput bold)$(tput setaf 2)./prepara.sh grx-mate-serv crea un instalador para una distro ubuntu-mate-serv 16.04 "
#echo "# $(tput bold)$(tput setaf 2)./prepara.sh grx-deb crea un paquete deb a partir del codigo fuente 16.04 "
echo "#                                                                             #"
echo "#                                                                             #"
echo "###############################################################################"



