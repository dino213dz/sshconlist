
#!/bin/sh

#Nom		: sshconlist.sh
#Description	: Affiche la liste des connections SHH établies sur la machine locale
#Ex)		: 
#Param 1	: 
#Version	: 1.0.0.0
#Auteur		: dino213dz@gmail.com
#Changelog	: 2019-01-10 00:43:05


################ VARIABLES : ################
c_red="\033[31m"
c_vert="\033[32m"
c_jaune="\033[33m"
c_bleu="\033[34m"
c_magenta="\033[35m"
c_cyan="\033[36m"
c_gris="\033[25;30m"
c_blanc="\033[24;30mm"
c_noir="\033[39m"
c_reset="\033[0m"

labels=$(netstat -plantu|grep "Adresse locale")
liste=$(netstat -lapute|grep -i "ssh" | grep -i "established")
liste_infos=$(who|grep -i "pt./[0-9]")

total_connections=$(netstat -lapute |grep -ic "established")

couleur_inc_min=32
couleur_inc_max=36
#couleur_inc=$couleur_inc_min
couleur_inc=32
################ FONCTIONS : ################

connectionTemps () {
	#$1= login
	#$2= ip
	#$3= ordre dans la liste
	login=$1
	ip=$2
	ordre=$3
	liste_infos=$(who|grep -i $login".*pt./[0-9].*("$ip")")
	col=1
	pos_date=3
	pos_heure=4
	pos_ip=5
	pos_fin=9
	retour=""
	numero=0
	for element in $liste_infos
	do
		if [ $col -eq 1 ];then
			numero=$(echo "$numero+1"|bc)					
			#echo "(num="$numero"/ordre="$ordre"/col="$col")"
		fi
		if [ $ordre -eq $numero ];then
			#echo "col="$col
			if [ $col -eq $pos_date ];then
				retour=$retour""$element
			fi
			if [ $col -eq $pos_heure ];then
				retour=$retour" "$element
				#col=0
				#break
			fi
			if [ $col -eq $pos_fin ];then
                                col=0
				break
                        fi
		#fi
		col=$(echo "$col+1"|bc)
		fi
	done
	echo $retour
}

connectionScreen () {
	echo "nul"
}

################ MAIN PROG : ################

#Format "Human"
if [ "$1" = "-H" ];then
	if [ $total_connections -gt 1 ];then pluriel="s";fi
	echo -e "\033[7m"$c_red" "$total_connections" "$c_reset" connexion"$pluriel" active"$pluriel"."$c_reset""
	position=0
	total=0
	for element in $liste
        do
		position=$(echo "$position+1"|bc)
		
		#on saute certaines couleurs
		if [ $couleur_inc -eq 34 ];then couleur_inc=36;fi #VERT JEUN ROUGE ;D
		
		#tcp indique le debut de ligne (ssh est en tcp)
		if [ "$element" = "tcp" ];then
			total=$(echo "$total+1"|bc)
			position=0
			element="\n["$total"]"$element
                fi
		#IP PORT distant
		if [ $position = 4 ];then
			ip_distante=$(echo $element|cut -d ":" -f 1)
			port_distant=$(echo $element|cut -d ":" -f 2)			
		fi
		#IP PORT local
		if [ $position = 3 ];then
                        ip_locale=$(echo $element|cut -d ":" -f 1)
                        port_local=$(echo $element|cut -d ":" -f 2)
                fi
		#LOGIN
		if [ $position = 6 ];then
                        login=$(echo $element|cut -d ":" -f 1)
		fi
		#PID
		if [ $position = 8 ];then
                        programme=$(echo $element|cut -d "/" -f 2)
			pid=$(echo $element|cut -d "/" -f 1)
                fi
		#PTY
		if [ $position = 9 ];then
                        sortie=$(echo $element|cut -d "@" -f 2)
			if [ "$sortie" = "[accept" ];then
				sortie="en cours d'authentification\033[7m(*)\033[0m"
			fi
                fi
		#Temps de connexion
		duree_connexion=$(connectionTemps $login $ip_distante $total)
		
		#si on arrive au dernier element de la ligne
		if [ $position -ge 9 ];then			
			echo -e "\033[7m\033["$couleur_inc"mn°"$total""$c_reset" User \033["$couleur_inc"m"$login""$c_reset" connecté sur \033["$couleur_inc"m"$ip_locale""$c_reset":\033["$couleur_inc"m"$port_local""$c_reset" depuis \033["$couleur_inc"m"$ip_distante""$c_reset":\033["$couleur_inc"m"$port_distant""$c_reset", sortie \033["$couleur_inc"m"$sortie""$c_reset", programme \033["$couleur_inc"m"${programme//:/}""$c_reset"(PID=\033["$couleur_inc"m"$pid""$c_reset") depuis \033["$couleur_inc"m"$duree_connexion""$c_reset"."
			#On incremente la couleur
			couleur_inc=$(echo "$couleur_inc+1"|bc)
			if [ $couleur_inc -gt $couleur_inc_max ];then
				couleur_inc=$couleur_inc_min
			fi
		fi
        done
#Format standard
else
	#afficher les labels et les formatter
	for label in $labels
	do
        	if [ "$label" = "Etat" ];then
                	label=""$label"\t\tUtilisateur"
	        fi
	        echo -en $label"\t"
	done
	#afficher les connexions et les formatter
	for element in $liste
	do
		if [ "$element" = "tcp" ];then
			element="\n"$element
		fi
		echo -en $element"\t"
	done
fi
##############o# FIN PROG : ################
echo -e ""
