#!/bin/bash
##################################################################
# Comprueba si somos root, si no, salimos
##################################################################
function root {
#comprobamos si somos root
if ! [ $(id -u) = 0 ]; then echo "$(tput bold) $(tput setaf 1)Hay que ejecutar el script como root$(tput sgr 0)"; exit 1; fi
}

##################################################################
# Muestra un error
##################################################################
function error {
	echo "${PROGNAME}: ${1:-"error desconocido"}" 1>&2
	echo "$(tput sgr 0)"
	exit 1

}

##################################################################
# Configura dns: deshabilita cualquier página que no sea moad.dipgra.es
##################################################################
function dns {
	echo "195.57.47.37 moad.dipgra.es moad" >> /etc/hosts
	echo "195.57.47.37 pre-moad.dipgra.es pre-moad" >> /etc/hosts
	mv /etc/resolv.conf /etc/resolv.conf.old
}


##################################################################
# Comprueba si estamos en un nodo b
##################################################################

function nodob(){

#Devuelve 0 para NODO B

if (ping -c1 -W1 10.1.1.50 &>> $LOG) && (ping -c1 -W1 8.8.8.8 &>> $LOG)
	then 
		return 1;	
	fi
	
if (ping -c1 -W1 10.1.1.50 &>> $LOG)
	then
		return 0;
	fi

return 1

}

##################################################################
# Configurando el proxy de los repositorios en la diputacion
##################################################################
function configura_proxy() {
	if (nodob) 
	then 
		echo "$(tput bold) $(tput setaf 1)"
		echo "Configurando el proxy de los repositorios en la diputacion"
		echo "----------------------------------------$(tput sgr 0)"
		echo 'Acquire::http::proxy "http://incidencias.dipgra.es:8080/";' >/etc/apt/apt.conf.d/00proxy
		echo 'Acquire::http::proxy::incidencias.dipgra.es "DIRECT";' >>/etc/apt/apt.conf.d/00proxy
	fi
	
}

##################################################################
# Instala dialog
##################################################################
function instala_dialog() {
  	cd $ruta/dialog
	if (actualizando_sistema)
		then 
			clear
			echo "No ha sido posible instalar dialog, apt-get esta bloqueado por estar ya en uso"
			echo "Esperando hasta que el sistema esté preparado .."
			while (actualizando_sistema);do
				echo "Esperando"
			done
			
		else
			dpkg -i *.deb	
			if [ $? -eq "0" ];then "Error inesperado, no se ha podido instalar dialog";return 1; fi
	fi
return 0
}

##################################################################
# Comprueba si ya estamos actualizando el sistema
##################################################################
function actualizando_sistema() {
##Comprobando si el sistema se esta actualizando
	if (gdbus call  --system --dest com.ubuntu.SystemService --object-path / --method com.ubuntu.SystemService.is_package_system_locked |grep true);then return 1;fi

return 0
}

##################################################################
# Fuerza la actualizacion del sistema
##################################################################
function fuerza_actualizacion() {
	if [ -f /var/lib/apt/lists/lock ] || [ -f /var/cache/apt/archives/lock ] || [ -f /var/lib/dpkg/lock ];then
		dialog --title "Instalación de servidor GrX_AE"  --yesno "Ya hay una aplicación actualizando el sistema\n Se suele tratar de actualizaciones automáticas\n     ¿Intentamos forzar la instalación?\n         ATENCION - NO SE ACONSEJA\nSe pueden producir errores inesperados \n    o quedar el sistema CORRUPTO" 0 0
		if [ $? -eq "0" ];then 
			echo "Borrando  /var/lib/dpkg/lock; /var/lib/apt/lists/lock; /var/cache/apt/archives/lock" >>$LOG
			fuser -k /var/lib/dpkg/lock; fuser -k /var/lib/apt/lists/lock; fuser -k /var/cache/apt/archives/lock
			if [ -f /var/lib/dpkg/lock ];then rm /var/lib/dpkg/lock;fi
			if [ -f /var/lib/apt/lists/lock ];then rm /var/lib/apt/lists/lock;fi
			if [ -f /var/cache/apt/archives/lock ];then rm /var/cache/apt/archives/lock;fi
			
	    	else
			echo "Saliendo del programa por decision del usuario" >>$LOG
			exit 1
	    	fi
	fi
return 0
}


##################################################################
# Actualizando sistema
##################################################################
function actualiza() {
		if (actualizando_sistema);then
			apt-get update
			if [ $? -ne "0" ];then return 1;fi
		fi
}


##################################################################
# Instalando ssh
################################################################## 
function instala_ssh() {
	apt-get -y install ssh
	if [ $? -ne "0" ];then return 1;fi
}



##################################################################
# Instalando firefox
################################################################## 
function instala_firefox() {
	cd $ruta/firefox
	dpkg -i *.deb
	apt-get -fy install
	#apt-get -y install firefox firefox-locale-es
	return $?
}

##################################################################
# Configurando iptables
################################################################## 
function iptables() {
	cd $ruta/iptables
	dpkg -i *.deb
	apt-get -fy install
	return $?
}

##################################################################
# Instalando lxde como WindowManager 
################################################################## 
function instala_lxde() {
	apt-get install -y xorg lxsession --force-yes
	echo lxsession -s LXDE -e LXDE > /etc/skel/.xsession
	return $?	
}
##################################################################
# Instalando xfce como WindowManager 
################################################################## 
function instala_xfce() {
	apt-get install -y xorg xfce4 xfce4-goodies --force-yes
	echo xfce4-session > /etc/skel/.xsession 
	return $?	
}


##################################################################
# Instalando fluxbox como WindowManager 
################################################################## 
function instala_fluxbox() {
	apt-get install -y xorg fluxbox --force-yes
	echo xfce4-session > /etc/skel/.xsession
	return $?
}

##################################################################
# Instalando blackbox como WindowManager 
################################################################## 
function instala_blackbox() {
	apt-get install -y xorg blackbox --force-yes
	echo blackbox > /etc/skel/.xsession
	return $?
}

##################################################################
# Instalando mate como WindowManager 
################################################################## 
function instala_mate() {
	apt-get -y install mate-core mate-desktop-environment mate-notification-daemon --force-yes
	echo mate-session > /etc/skel/.xsession
	return $?
}

##################################################################
# Instalamos xrdp de 16.10
################################################################## 
function xrdp1610() {
	cd $ruta/xrdp-deb/
	dpkg -i xorgxrdp.deb	
	dpkg -i xrdp.deb
	apt-get -fy install 
	return $?
}

##################################################################
# Instalando paquetes para el dominio
################################################################## 
function instala_dominio() {
	cd $ruta/grx-dominio
	apt-get install -y debconf-utils
	debconf-set-selections kerberos.seed
	dpkg -i grx-dominio-srv.deb
	apt-get -fy install 
	if [ $? -ne "0" ];then return 1;fi 
	if [ -f /etc/network/interfaces ]; then
		if grep -q dns-nameservers /etc/network/interfaces; then
	    	    echo "Ya tiene dns instalados"
		else
		    echo "dns-nameservers 10.1.1.50 10.1.1.60" >> /etc/network/interfaces 
		    echo "dns-search grx" >> /etc/network/interfaces    
		fi
	fi
}
##################################################################
# Integrando en el servidor de dominio
################################################################## 
function dominio() {

	grx-dominio
	if [ $? -ne "0" ];then return 1;fi 	
	#usuario=$(dialog --inputbox  "Introduce un usuario con permisos en AD: " 7 55 --stdout)
	#clave=$(dialog --insecure --passwordbox "Introduce la contraseña de: "$usuario 7 55 --stdout)
	#echo $clave | kinit $usuario
	#net ads keytab add termsrv
	#chmod uag+r /etc/krb5.keytab
}

##################################################################
# Instala Autofirma
##################################################################
function instala_autofirma() {
	echo "Instalo Autofirma"
	echo "---------------------------"
	cd $ruta/autofirma
	dpkg -i *.deb
	if [ $? -ne "0" ];then apt-get -fy install;fi 
}

##################################################################
# Instala Aplicaciones auxilires
##################################################################
function instala_auxiliares() {
	cd $ruta/aplicaciones_auxiliares
	dpkg -i *.deb
	if [ $? -ne "0" ];then apt-get -fy install;fi 
	echo "Instalo Evince (PDF)"
	echo "---------------------------"
	

}

##################################################################
# Instala OpenOffice 4.1
##################################################################
function instala_openoffice() {
	echo "Instalo openoffice 4.1."
	echo "---------------------------"
	cd $ruta/oo
	dpkg -i *.deb
	if [ $? -ne "0" ];then return 1;fi 
	if [ ! -f /opt/openoffice4/program/libjawt.so ];then 
        	ln -s /usr/local/java/jre1.8.0_111/lib/amd64/libjawt.so /opt/openoffice4/program
	fi
}

##################################################################
# Movemos los archivos a sus carpetas...
################################################################## 
function mueve_archivos() {
	echo "Instalamos los archivos de teclado y logos..."
	echo "-----------------------"

	cd $ruta/xrdp_etc
	mv * /etc/xrdp/

	echo "Creamos los enlaces a xrdp"
	echo "-----------------------"


	if [ -f /etc/X11/Xsession ];then 
		mv  /etc/X11/Xsession /etc/X11/Xsession.old
	fi
	cp /etc/xrdp/startwm.sh /etc/X11/Xsession

	if [ ! -d /usr/share/doc/xrdp ];then 
		mkdir -p /usr/share/doc/xrdp
	fi

	if [ ! -f /usr/share/doc/xrdp/rsakeys.ini ];then 
		cp /etc/xrdp/rsakeys.ini /usr/share/doc/xrdp/rsakeys.ini
	fi
	
	# Ponemos el teclado en las sesiones xrdp
	cd /etc/xrdp 
	setxkbmap -layout es,es

	#Desactivamos errores
	sed -i.bak 's/enabled=1/enabled=0/g' /etc/default/apport


}

##################################################################
# Instalamos paquetes para dni-e y eToken
#Instalamos la aplicacion de gestion de eToken
#Lo tenemos en el archivo comprimido sac9.1_linux.zip 
#Una vez instalados podemos comprobar el lector con pcsc_scan y metemos el dnie o eToken
#Nos muestra la info del dni o eToken
#Para eToken de Carlos debemos instalar por orden los deb y despues crear un dispositivo nuevo
#Necesitamos poner en firefox -> preferencias -> avanzado -> certificado -> dispositivos de seguridad -> cargar -> nombre eToken; Archivo /usr/lib/libeTPkcs11.so
#Para el DNI... 
#Necesitamos poner en firefox -> preferencias -> avanzado -> certificado -> dispositivos de seguridad -> cargar -> nombre DNI; Archivo /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
#Importamos los certificados de la FNMT
#En firefox -> certificados -> autoridades -> importamos AC RAIZ DNIE (marcamos las tres casillas)
#En firefox -> certificados -> servidores -> importamos OCSP_VADNIE_FNMT_SHA2.cer
# Lo podemos probar en https://www.dnielectronico.es/PortalDNIe/PRF1_Cons02.action?pag=REF_320
# Pagina del etoken de Carlos http://www.safenet-inc.es/multi-factor-authentication/authenticators/pki-usb-authentication/etoken-5100-usb-token/
# Pagina principal http://www.safenet-inc.es/
################################################################## 
function dnie() {
	apt-get install -y pcscd pcsc-tools opensc opensc-pkcs11 ;if [ $? -ne "0" ];then return 1;fi
	dpkg -i $ruta/etoken/libhal1_0.5.14-8_amd64.deb ;if [ $? -ne "0" ];then return 1;fi
	dpkg -i $ruta/etoken/libhal-storage1_0.5.14-8_amd64.deb ;if [ $? -ne "0" ];then return 1;fi
	dpkg -i $ruta/etoken/SafenetAuthenticationClient-9.1.7-0_amd64.deb ;if [ $? -ne "0" ];then return 1;fi
}

##################################################################
# Instalamos jre_openoffice
################################################################## 
function instala_jre_openoffice() { 
	echo "$(tput bold) $(tput setaf 3)Instalando java 1.8.0_111$(tput sgr 0)"
	if [ ! -d /usr/local/java ];then mkdir -p /usr/local/java;fi
	cd $ruta/java/
	tar xvzf jre-8u111-linux-x64.tar.gz &> /dev/null
	cp -r ./jre1.8.0_111 /usr/local/java/
        if (! grep "--weboffice--" /etc/profile > /dev/null);then
		echo  "#--weboffice--" >> /etc/profile
		echo "UNO_PATH=/opt/openoffice4/program" | sudo tee --append /etc/profile
		echo "JAVA_HOME=/usr/local/java/jre1.8.0_111" | sudo tee --append /etc/profile
		echo "PATH=$PATH:$HOME/bin:$JAVA_HOME/bin:/opt/openoffice4/program" | sudo tee --append /etc/profile
		echo "export JAVA_HOME" | sudo tee --append /etc/profile
		echo "export PATH" | sudo tee --append /etc/profile
		echo "export UNO_PATH" | sudo tee --append /etc/profile
	fi
	#Ya tenemos el directorio jre1.8.0_111-linux-x64.tar.gz y todos sus archivos
	#abrimos /etc/profile y añadimos las lineas al final (pongo también UNO_PATH para weboffice)

	update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jre1.8.0_111/bin/java" 1
	update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/java/jre1.8.0_111/bin/javaws" 1
	update-alternatives --set java /usr/local/java/jre1.8.0_111/bin/java
	update-alternatives --set javaws /usr/local/java/jre1.8.0_111/bin/javaws
	source /etc/profile
	#Instalamos plugin en firefox
	mkdir -p /usr/lib/firefox-addons/plugins
	cd /usr/lib/firefox-addons/plugins
	if [ ! -f /usr/lib/firefox-addons/plugins/libnpjp2.so ];then 
		ln -s /usr/local/java/jre1.8.0_111/lib/amd64/libnpjp2.so 
	fi
	
	#Creamos enlace para el Panel de Control de java
	if [ ! -f /usr/share/applications/sun_java.desktop ];then 
		cp /usr/local/java/jre1.8.0_111/plugin/desktop/sun_java.desktop /usr/share/applications
	fi
	
	cp /usr/local/java/jre1.8.0_111/plugin/desktop/sun_java.png /usr/share/icons

	if [ ! -f /usr/local/bin/jcontrol ];then 
		ln -s /usr/local/java/jre1.8.0_111/bin/jcontrol /usr/local/bin/jcontrol
	fi
	
	#Ponemos a mano excepciones java
	#/usr/local/java/jre1.8.0_111/bin/ControlPanel
}


##################################################################
# Instalamos certificados para java
#Para agregar un certificado a un almacén de certificados CA en JAVA
#En una consola en la carpeta %ruta%\jre\lib\security del JDK, 
#ejecuta el siguiente comando para ver qué certificados están instalados:
#    keytool -list -keystore cacerts
#Solicitará la contraseña del almacén. La contraseña predeterminada es changeit. Se puede y debe cambiar la clave. 
#Guardamos el certificado (p.ejemplo el de camefirma es CamefirmaCorporateServerII-2015.crt) en la carpeta %ruta%\jre\lib\security.
#Importamos el certificado con:
#sudo keytool -keystore cacerts -importcert -alias Camefirma -file CamefirmaCorporateServerII-2015.crt
#Nos solicita la clave del contenedor (changeir si no la hemos cambiado) y ya tenemos en java la entidad
#Podemos volver a comprobar con  keytool -list -keystore cacerts
# Para más info de keytool en http://docs.oracle.com/javase/7/docs/technotes/tools/windows/keytool.html
##################################################################

function instala_certificados_java() {
	cd $ruta
	if [ -d /usr/local/java/jre1.8.0_111/lib/security ];then 
		cp ./certificados/cacerts /usr/local/java/jre1.8.0_111/lib/security
	fi


}

##################################################################
# Instalamos perfiles
##################################################################

function instala_perfiles() {
	echo "$(tput bold) $(tput setaf 3)Instalando perfiles$(tput sgr 0)"
	apt-get install -y zenity
	cd $ruta/profile 
	tar xvf profile.tar 
	if [ -f /etc/xdg/menus/xfce-applications.menu ];then
		mv /etc/xdg/menus/xfce-applications.menu /etc/xdg/menus/xfce-applications.menu.old		
	fi
	cp $ruta/profile/xfce-applications.menu /etc/xdg/menus/
	if [ -d /usr/share/icons/Logos_GrX ];then
		mv /usr/share/icons/Logos_GrX /usr/share/icons/Logos_GrX.old		
	fi
	cp -R $ruta/profile/Logos_GrX /usr/share/icons/
	cp -R $ruta/profile/Logos_GrX/LogoGrX*.png /usr/share/backgrounds/
	cp -R $ruta/profile/autoconfig.js /usr/lib/firefox/defaults/pref/
	cp -R $ruta/profile/mozilla.cfg /usr/lib/firefox/
	cp -R $ruta/profile/.java* /etc/skel
	cp -R $ruta/profile/.profile /etc/skel

	# Quitamos aplicaciones en autoarranque
	if [ -d /etc/skel/.config/autostart/ ];then 
		rm -R /etc/skel/.config/autostart
	fi
	cp -R $ruta/profile/.config /etc/skel
	cp -R $ruta/profile/.wo5 /etc/skel
	cp -R $ruta/profile/.mozilla /etc/skel
	cp -R $ruta/profile/Escritorio /etc/skel
	cp -R $ruta/profile/.openoffice /etc/skel
	cp -R $ruta/profile/moad.png /usr/share/icons
	cp -R $ruta/profile/grx-certificados /usr/bin
	cp -R $ruta/profile/attrib.sh /usr/bin
	cp -R $ruta/profile/Manuales /etc/skel
	chmod 755 /usr/bin/grx-certificados
	#Ocultamos los programas en los menus
	echo "NoDisplay=true" >> /usr/share/applications/debian-uxterm.desktop
	echo "NoDisplay=true" >> /usr/share/applications/debian-xterm.desktop
	echo "NoDisplay=true" >> /usr/share/applications/byobu.desktop
	echo "NoDisplay=true" >> /usr/share/applications/ristretto.desktop
	echo "NoDisplay=true" >> /usr/share/applications/globaltime.desktop
	echo "NoDisplay=true" >> /usr/share/applications/openoffice4-base.desktop
	echo "NoDisplay=true" >> /usr/share/applications/openoffice4-calc.desktop
	echo "NoDisplay=true" >> /usr/share/applications/openoffice4-draw.desktop
	echo "NoDisplay=true" >> /usr/share/applications/openoffice4-impress.desktop
	echo "NoDisplay=true" >> /usr/share/applications/openoffice4-javafilter.desktop
	echo "NoDisplay=true" >> /usr/share/applications/openoffice4-math.desktop
	echo "NoDisplay=true" >> /usr/share/applications/openoffice4-printeradmin.desktop
	echo "NoDisplay=true" >> /usr/share/applications/openoffice4-startcenter.desktop

	echo "NoDisplay=true" >> /usr/share/applications/python3.5.desktop
	echo "NoDisplay=true" >> /usr/share/applications/pavucontrol.desktop
	echo "NoDisplay=true" >> /usr/share/applications/Thunar-folder-handler.desktop
	echo "NoDisplay=true" >> /usr/share/applications/thunar-settings.desktop

	echo "NoDisplay=true" >> /usr/share/applications/mimeinfo.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce4-run.desktop
	echo "NoDisplay=true" >> /usr/share/applications/vim.desktop
	echo "NoDisplay=true" >> /usr/share/applications/thunar-volman-settings.desktop


	echo "NoDisplay=true" >> /usr/share/applications/xarchiver.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce-workspaces.desktop
	echo "NoDisplay=true" >> /usr/share/applications/exo-mail-reader.desktop
	echo "NoDisplay=true" >> /usr/share/applications/exo-file-manager.desktop
	echo "NoDisplay=true" >> /usr/share/applications/exo-preferred-applications.desktop
	echo "NoDisplay=true" >> /usr/share/applications/exo-terminal-emulator.desktop

	echo "NoDisplay=true" >> /usr/share/applications/xfburn.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce4-about.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce4-appfinder.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce4-accesibility-settings.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce4-run.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce4-terminal.desktop
	echo "NoDisplay=true" >> /usr/share/applications/exo-terminal-emulator.desktop

	echo "NoDisplay=true" >> /usr/share/applications/gscriptor.desktop
	echo "NoDisplay=true" >> /usr/share/applications/python2.7.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfcalendar.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce4-clipman.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce4-powermanager-settings.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce4-settings-editor.desktop
	echo "NoDisplay=true" >> /usr/share/applications/xfce4-dict.desktop

	#Ponemos idioma en castellano
	/usr/share/locales/install-language-pack es_ES
	echo 'LANG="es_ES.UTF-8"' >> /etc/environment
	echo 'LC_ALL="es_ES.UTF-8"' >> /etc/environment
	echo 'LANGUAGE="es_ES"' >> /etc/environment
	echo 'LANG="es_ES.UTF-8"' >> /etc/default/locale
	echo 'LC_ALL="es_ES.UTF-8"' >> /etc/default/locale
	echo 'LANGUAGE="es_ES"' >> /etc/default/locale
	if [ -f /var/lib/locales/supported.d/en ];then 
		rm  /var/lib/locales/supported.d/en
	fi
	#Instalamos language-pack-gnome-es de gnome para evince
	apt-get install -y language-pack-gnome-es
	update-locale
	dpkg-reconfigure locales
	
}


##################################################################
# Usamos x11vnc sesman
################################################################## 
function instala_x11vnc() {
	apt-get -y install x11vnc
	if [ $? -ne "0" ];then return 1;fi
}

function reinicia() {
	echo "Reiniciamos el sistema"
	echo "----------------------------"
	shutdown -r now 
}

