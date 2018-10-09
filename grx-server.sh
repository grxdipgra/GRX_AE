#!/bin/bash
################################################################
# Nombre del script : grx-ae.sh
# Descripcion : Descomprime los archivos necesarios, configura e instala GRX_AE 
# adaptandolasudo  a las necesidades de la Diputacion de Granada
# Creado por Alberto Avidad
clear
echo " ###################################################################"
echo " # Nombre del script : $(tput bold)instalador  $(tput sgr 0)                                #"
echo " # Descripcion : Instala xrdp, java, weboffice, etoken, libreoffice#"
echo " # autofirma, certificados FNMT, DNI...sobre ubuntu-mate           #"
echo " # Creado por $(tput bold) $(tput setab 6)Alberto Avidad Fernandez$(tput sgr 0) $(tput bold) Oficina de Software Libre$(tput sgr 0) #"
echo " ###################################################################"
echo ""
trap 'limpia' ERR SIGHUP SIGINT SIGTERM

function limpia {
  cd $PREV
  sudo rm -rf $TMPDIR
  echo "Limpiando $TMPDIR"
  exit 0
}


function somos_root {
if ! [ $(id -u) = 0 ]; then echo "$(tput bold) $(tput setab 1) ATENCION - Hay que ejecutar el script como root$(tput sgr 0)"; exit 1; fi
}


function instala {
	cd $TMPDIR/xrdp_tar
	chmod 755 install-server.sh
	./install-server.sh
}

function descomprime {
	echo "$(tput bold) $(tput setaf 3)Descomprimiendo archivos necesarios$(tput sgr 0)"
	SKIP=`awk '/^__AQUI_SIGUE_EL_BINARIO__/ { print NR + 1; exit 0; }' $0`
	tail -n +$SKIP $0 |tar xvf - -C $TMPDIR &> /dev/null
}


#####MAIN#######
export TMPDIR=`mktemp -d /tmp/extrae.XXXXXX`
export PREV=`pwd`

somos_root && descomprime &&instala && limpia

exit 0
__AQUI_SIGUE_EL_BINARIO__
