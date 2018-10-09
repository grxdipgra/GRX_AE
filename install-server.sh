#!/bin/bash
#set -e 
LOG=/var/log/instala_server.log
ruta=$(pwd)
PROGNAME=$(basename $0)
porcentaje=5

source libreria.sh

echo "$(tput bold) $(tput setaf 3)Configurando proxy y actualizando paquetes$(tput sgr 0)"
if (configura_proxy);then echo "Configurado proxy" >> $LOG;fi
let "porcentaje+=5"

echo "Instalando dialog"
if (instala_dialog);then echo "dialog instalado" >> $LOG;else echo "No se ha podido instalar dialog y es un paquete necesario para esta aplicacion";exit 1; fi
let "porcentaje+=5"

dialog --title "GrX - Instalando Administracion Electronica" --exit-label Aceptar --textbox texto 0 0

echo $porcentaje | dialog --gauge "Actualizando el sistema...sea paciente" 10 70 0
if (actualiza);then echo "Sistema actualizado" >> $LOG;else echo "No se ha podido actualizar el sistema";exit 1; fi
let "porcentaje+=5"

funch=(dialog --separate-output --checklist "Selecciona que paquetes quiere instalar:" 0 0 0)
opciones=(1 "Servidor Xrdp" on
 2 "Windows Manager" on
 3 "Servidor ssh" on
 4 "Driver para dnie" on
 5 "Navegador Firefox" on
 6 "Instalar Java 1.8.111_openoffice" on
 7 "Instalar OpenOffice 4.2" on
 8 "Configurando Perfiles" on
 9 "Instalando certificados java" on
 10 "Instalando Autofirma" on
 11 "Instala aplicaciones auxilires" on
 12 "Configura xrdp" on
 13 "Integrar en el dominio" on
 14 "Configura iptables" on)
selecciones=$("${funch[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
clear
for seleccion in $selecciones
do
 case $seleccion in
 1)
	echo $porcentaje | dialog --gauge "Instalando servidor xrdp" 10 70 0
	if (xrdp1610);then echo "Servidor xrdp instalado" >> $LOG;else echo "No se ha podido instalar xrdp";exit 1; fi
	let "porcentaje+=10"
 ;;

 2)
 	funcheck=(dialog --separate-output --checklist "Selecciona que Windows Manager quiere instalar:" 0 0 0)
	opci=(1 "Mate" off
	 2 "Fluxbox" off
	 3 "LXDE" off
	 4 "Blackbox" off
	 5 "Xfce" on)
	selec=$("${funcheck[@]}" "${opci[@]}" 2>&1 >/dev/tty)
	clear
	for sel in $selec
	do
	 case $sel in
	 1)
	 	echo $porcentaje | dialog --gauge "Instalando Mate" 10 70 0
		let "porcentaje+=5"
		if (instala_mate);then echo "Mate instalado" >> $LOG;else echo "No se ha podido instala mate";exit 1; fi
	 ;;
	 2)
	 	echo $porcentaje | dialog --gauge "Instalando Fluxbox" 10 70 0
		if (instala_fluxbox);then echo "Fluxbox instalado" >> $LOG;else echo "No se ha podido instala fluxbox";exit 1; fi
	 	let "porcentaje+=5"
	 ;;
	 3)
	 	echo $porcentaje | dialog --gauge "Instalando LXDE" 10 70 0
	 	if (instala_lxde);then echo "Servidor lxde instalado" >> $LOG;else echo "No se ha podido instala lxde";exit 1; fi
	 	let "porcentaje+=5"
	 ;;
	 4)
	 	echo $porcentaje | dialog --gauge  "Instalando Blackbox" 10 70 0
		if (instala_blackbox);then echo "Blackbox instalado" >> $LOG;else echo "No se ha podido instala blackbox";exit 1; fi
		let "porcentaje+=5"
	 ;;
	 5)
	 	echo $porcentaje | dialog --gauge  "Instalando Xfce" 10 70 0
		if (instala_xfce);then echo "Xfce instalado" >> $LOG;else echo "No se ha podido instalar xfce";exit 1; fi
		let "porcentaje+=5"
	 ;;

	 esac
	done

 ;;

 3)
	echo $porcentaje | dialog --gauge "Instalando servidor ssh" 10 70 0
	if (instala_ssh);then echo "Servidor ssh instalado" >> $LOG;else echo "No se ha podido instala ssh";exit 1; fi
	let "porcentaje+=5"
 ;;
 4)
	echo $porcentaje | dialog --gauge "Instalando driver DNIe" 10 70 0
	if (dnie);then echo "dnie instalado" >> $LOG;else echo "No se ha podido instalar dnie";exit 1; fi
	let "porcentaje+=10"
 ;;
 5)
	echo $porcentaje | dialog --gauge "Instalando navegador Firefox" 10 70 0
	#$(( instala_firefox )2>&1)>>$LOG
	if (instala_firefox);then echo "firefox instalado" >> $LOG;else echo "No se ha podido instalar firefox";exit 1; fi
	let "porcentaje+=10"
 ;;
 6)
	echo $porcentaje | dialog --gauge "Instalando Java 1.8.111" 10 70 0
	#$(( instala_jre )2>&1)>>$LOG
	if (instala_jre_openoffice);then echo "java instalado" >> $LOG;else echo "No se ha podido instalar java";exit 1; fi
	let "porcentaje+=10"
 ;;
 
 7)
	echo $porcentaje | dialog --gauge "Instalando OpenOffice 4.2" 10 70 0
	if (instala_openoffice);then echo "Openoffice instalado" >> $LOG;else echo "No se ha podido instalar openoffice";exit 1; fi
	let "porcentaje+=10"
 ;;

 8)
	echo $porcentaje | dialog --gauge "Configurando perfiles"  10 70 0
	if (instala_perfiles);then echo "Instalo Perfiles" >> $LOG;else echo "No se ha podido instalar perfiles";exit 1; fi
	let "porcentaje+=5"
 ;;
 9)
	echo $porcentaje | dialog --gauge "Instalando los certificados en Java" 10 70 0
	if (instala_certificados_java);then echo "Certificados de java instalados" >> $LOG;else echo "No se ha podido instalar java certificados";exit 1; fi
	let "porcentaje+=5"
 ;;
 10)
	echo $porcentaje | dialog --gauge "Instalo Autofirma"  10 70 0
	if (instala_autofirma);then echo "Instalo Autofirma" >> $LOG;else echo "No se ha podido instalar autofirma";exit 1; fi
	let "porcentaje+=5"
 ;;
 11)
	echo $porcentaje | dialog --gauge "Instalando aplicaciones auxiliares" 10 70 0
	if (instala_auxiliares);then echo "Instalando aplicaciones auxiliares" >> $LOG;else echo "No se pueden instalar aplicaciones auxiliares";exit 1; fi
	let "porcentaje+=2"
 ;;
 12)
	echo $porcentaje | dialog --gauge "Configurando xrdp" 10 70 0
	if (mueve_archivos);then echo "Configurando xrdp" >> $LOG;else echo "No se ha podido configurar xrdp";exit 1; fi
	let "porcentaje+=5"
 ;;
 13)
	dialog --title "Instalación de servidor GrX_AE"  --yesno "¿Desea integrar el servidor en el dominio?" 0 0
	if [ $? -eq "0" ];then 
			echo $porcentaje | dialog --gauge "Integrando el servidor en el dominio" 10 70 0
	        	if (instala_dominio);then echo "Instalando paquetes necesarios para integrar el servidor en el dominio" >> $LOG;else echo "No se han podido instalar los paquetes necesarios para integrar el servidor en el dominio";exit 1; fi
			dominio
	fi
 ;;
 14)
	echo $porcentaje | dialog --gauge "Configurando iptables" 10 70 0
	if (iptables);then echo "Configurando iptables" >> $LOG;else echo "No se ha podido configurar iptables";exit 1; fi
	let "porcentaje+=5"
 ;;

 esac
done


dialog --title "Instalación de servidor GrX_AE"  --yesno "¿Desea reiniciar el servidor?" 0 0
if [ $? -eq "0" ];then 
        reboot
fi

exit 0

