#!/bin/bash


#========VARIABLES======= :=>
fecha_log=`date +"%d/%m/%Y->%H:%M"`
i=1
archivo_html='/var/www/html/htdocs/fct/html/temp.html'
cuenta_td=1
n_tablas=0
ini=1
fin=0
#=======RELLENAR ESTOS DATOS======= :=>
parte_red=`echo "192.168.1"`
mascara=`echo "/24"`

#=======BORRADO DE FICHEROS=======:=>
rm -f /var/www/html/htdocs/fct/log/resultado_ping.txt &> /dev/null
rm -f ${archivo_html} &> /dev/null

#=======SCRIPT=======:=>
#como saber si estamos en la misma red que la puesta por el admin
ip a s | grep inet | grep $parte_red &> /dev/null

#comprobar si la ip esta activa/inactiva
	if [ $? -ne 0 ]
	then
		#comprobacion si la RED puesta por el Admin esta bien
		echo "[ ${fecha_log} ] :=> La red introducida es invalida [NO ESTAS EN ESA RED]" &>> /var/www/html/htdocs/fct/log/log.txt
		exit 1 # salimos del script y lo guardamos en un log
	fi

	for (( ${i}; ${i}<5; i++ ))
	do
		ping -s 1 -c 1 ${parte_red}"."${i} &>/dev/null

		case $?
		in
			0)
				echo ${parte_red}"."${i}"#correcto" >> /var/www/html/htdocs/fct/log/resultado_ping.txt
			;;
			*)
				echo ${parte_red}"."${i}"#in-correcto" >> /var/www/html/htdocs/fct/log/resultado_ping.txt
			;;
		esac
	done

	n_lineas=`wc /var/www/html/htdocs/fct/log/resultado_ping.txt | awk -F " " '{print $1}'`
	let resto=${n_lineas}%10
	if [ ${resto} -eq 0 ]
	then
		let n_tablas=$n_lineas/10
	else
		let n_tablas=($n_lineas/10)+1
	fi

	cuantos_tds=`wc /var/www/html/htdocs/fct/log/resultado_ping.txt | awk -F " " '{print $1}'`

#formado del HTML
	echo "<html>">> ${archivo_html}
	echo "<head>" >> ${archivo_html}
	echo "<title>IPS-ACTIVAS/INACTIVAS</title>">> ${archivo_html}
	echo "<meta charset=\"utf-8\">" >> ${archivo_html}
	echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"./css/estilos.css\"/>" >> ${archivo_html}
	echo "<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">" >> ${archivo_html}
	echo "<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>" >> ${archivo_html}
    	echo "<link href=\"https://fonts.googleapis.com/css2?family=Slabo+27px&display=swap\" rel=\"stylesheet\">" >> ${archivo_html}
	echo "</head>" >> ${archivo_html}
	echo "<body>" >> ${archivo_html}
	echo "<script src=\"/var/www/html/htdocs/fct/html/JavaScript/java.js\"></script>" >> ${archivo_html}
	echo "<div id=\"div0\">">> ${archivo_html}
	echo "<h1>WEB MONITORIZACIÓN</h1>" >> ${archivo_html}
	echo "<img src=\"./img/logo.png\" id=\"logo\"><br>" >> ${archivo_html}
	echo "</div>">> ${archivo_html}
	echo "<form action=\"./php/discos.php\" method=\"post\" name=\"formu\">" >> ${archivo_html}
	echo "<fieldset id=\"caja0\">" >> ${archivo_html}
    	echo "<legend class=\"titulo\">Obtener Informacion de los Discos</legend>" >> ${archivo_html}
	echo "Password SSH <input type=\"password\" name=\"pass\">" >> ${archivo_html}
	echo "<input type=\"submit\" name=\"discos\" value=\"Escanear\">" >> ${archivo_html}
	echo "</fieldset><br>" >> ${archivo_html}
	echo "</form>" >> ${archivo_html}
	for ((k=0;k<$n_tablas;k++))
	do
		echo "<table border='1'>" >> ${archivo_html}
		echo "<tr>" >> ${archivo_html}
		echo "<td id=\"td_ip\">IP [ ACTIVA/INACTIVA ]</td>" >> ${archivo_html}
		echo "<td>Acciones</td>" >> ${archivo_html}
		echo "</tr>" >> ${archivo_html}
		echo "<tr>" >> ${archivo_html}
		let fin=$ini+9
		for linea in `cat /var/www/html/htdocs/fct/log/resultado_ping.txt | awk -v ini=$ini -v fin=$fin 'NR==ini, NR==fin'`
		do
			ip=`echo ${linea} | awk -F "#" '{print $1}'`
			estado=`echo ${linea} | awk -F "#" '{print $2}'`
			if [ $estado = "correcto" ]
			then
				echo "<td bgcolor=\"green\">${ip}</td>" >> ${archivo_html}
				echo "<td><form name=\"formu\" action=\"./php/acciones.php\"><input type=\"hidden\" name=\"ip\" value=\"${ip}\"><input class=\"accion\" type=\"submit\" name=\"envio\" value=\"Accion\"></form></td>" >> ${archivo_html}
				echo "</tr>" >> ${archivo_html}
			else
				echo "<td bgcolor=\"orange\">${ip}</td>" >> ${archivo_html}
				echo "<td><form name=\"formu\" action=\"./php/acciones.php\"><input type=\"hidden\" name=\"ip\" value=\"${ip}\"><input class=\"accion\" type=\"submit\" name=\"envio\" value=\"Accion\"></form></td>" >> ${archivo_html}
				echo "</tr>" >> ${archivo_html}
			fi
		done
		echo "</table>" >> ${archivo_html}
		let ini=$ini+10
	done
	echo "</body>" >> ${archivo_html}
        echo "</html>" >> ${archivo_html}

# copiado del HTML al servidor XAMP

	cp -f /var/www/html/htdocs/fct/html/temp.html  /var/www/html/htdocs/fct/html/ips.html




































