#Identificacao de interfaces de rede
ls /sys/class/net > /tmp/if.txt     #Lista as interfaces e escreve no arquivo if.txt
numero=$(wc -l < /tmp/if.txt)       #Conta a quantidade de interfaces(linhas) do sistema 
interface=(inexistente inexistente inexistente inexistente inexistente)
#Se a quantidade de interfaces for menor ou igual a 4 escreve nas posicoes de 0 a 3 do vetor de interfaces
if [ $numero -le 4 ];then
contador=1
until [ $contador -gt $numero ];do
interface[$contador]=$(sed -n $contador'p' /tmp/if.txt) 
let contador+=1
done
fi

#Conf manual

#Configuracao manual IPV4
ip=( - - - - - )
function config_if(){
	
	dialog	--title "Configuracao Manual" \
		--menu "Escolha uma opcao" 0 0 0 \
	        "IPv4" "Configura interfaces de rede IPv4" \
	        "IPv6" "Configura interfaces de rede IPv6" \
	        "Roteamento" "Configura rotas de redes com interfaces de IPv6 ou IPv4" \
	        "SNAT" "Realiza SNAT via Iptables" \
		VOLTAR '' 2> /tmp/opcao
		opt=$(cat /tmp/opcao)
		case $opt in

	    "IPv4")
			config_endereco 4
		;;

	    "IPv6")
			config_endereco 6
		;;
	    "Roteamento")
			m_rota
		;;
	    "SNAT")
			m_snaat
		;;
		"VOLTAR")
		voltar
		;;

		esac
		}
	

	endereco_ip(){

		if [ $1 -eq 4 ]; then

				dialog	--title "Configuracao IPv4" \
					--inputbox "Favor Digitar Endereco_IP/(CIDR)" 0 0 2>/tmp/eth.conf
					sudo ip addr flush dev ${interface[$2]}
					sudo ip link set ${interface[$2]} up 
					ip[$2]=$(cat /tmp/eth.conf)
					sudo ip  addr add ${ip[$2]} dev ${interface[$2]}  
				    sudo ip  addr show dev ${interface[$2]} >/tmp/eth.log
					dialog	--backtitle "Resultado Configuracao.." \
						--textbox /tmp/eth.log 22 70
					config_if

				else

					dialog	--title "Configuracao IPv6" \
					--inputbox "Favor Digitar Endereco_IP/(CIDR)" 0 0 2>/tmp/eth.conf
					sudo ip addr flush dev ${interface[$2]}
					sudo ip link set ${interface[$2]} up 
					ip[$2]=$(cat /tmp/eth.conf)
					sudo ip -6 addr add ${ip[$2]} dev ${interface[$2]}  
				    sudo ip -6 addr show dev ${interface[$2]} >/tmp/eth.log
					dialog	--backtitle "Resultado Configuracao.." \
						--textbox /tmp/eth.log 22 70
					config_if
				fi
		}

config_endereco(){

	dialog	--title "Interface para configuracao" \
		--menu "Escolha a Interface que se deseja configura endereco IP" 0 0 0 \
	        "${interface[1]}" "Interface de rede 1" \
	        "${interface[2]}" "Interface de rede 2" \
	        "${interface[3]}" "Interface de rede 3" \
			"${interface[4]}" "Interface de rede 4" \
		VOLTAR '' 2> /tmp/opcao
		opt=$(cat /tmp/opcao)
		
		case $opt in

			"${interface[1]}")
			endereco_ip $1 1
				;;

			"${interface[2]}")
			endereco_ip $1 2
				;;

			"${interface[3]}")
			endereco_ip $1 3
				;;

			"${interface[4]}")
			endereco_ip $1 4
				;;

			"VOLTAR")
			config_if	
				;;

			*)
				echo "Opcao Errada"
				;;
			esac
}

rota_interface="-"
m_rota(){

	dialog	--title "Configuracao Rota estatica" \
		--menu "Escolha um protocolo IP para adicionar uma rota" 0 0 0 \
	        "Protocolo IPv4" "Adiciona rota estatica na tabela IPv4" \
	        "Protocolo IPv6" "Adiciona rota estatica na tabela IPv6" \
		VOLTAR '' 2> /tmp/opcao
		opt=$(cat /tmp/opcao)
		case $opt in
		"Protocolo IPv4")

			dialog --title "Escolha o tipo de rota" \
					--menu "Rota para rede especifica, ou rota default" 0 0 0 \
					"Rota default" "" \
					"Rota para rede especifica" "" \
					"VOLTAR" '' 2> /tmp/opcao
					opt=$(cat /tmp/opcao)
					case $opt in

		"Rota default")
		digita_rota 1
		ip route add default via $rota_salto dev $rota_interface
		m_rota
		;;
		"Rota para rede especifica")
		digita_rota 2
		ip route add $rota_ip via $rota_salto dev $rota_interface
		m_rota
		;;

		"VOLTAR")
		m_rota	
		;;
					esac
					
		;;

		"Protocolo IPv6")

			dialog --title "Escolha o tipo de rota" \
					--menu "Rota para rede especifica, ou rota default" 0 0 0 \
					"Rota default" "" \
					"Rota para rede especifica" "" \
					VOLTAR '' 2> /tmp/opcao
					opt=$(cat /tmp/opcao)
					case $opt in

		"Rota default")
		digita_rota 1
		ip -6 route add default via $rota_salto dev $rota_interface
		m_rota
		;;
		"Rota para rede especifica")
		digita_rota 2
		ip -6 route add $rota_ip via $rota_salto dev $rota_interface
		m_rota
		;;

		"VOLTAR")
		m_rota	
		;;
					esac
		;;

		"VOLTAR")
		config_if
		;;

		esac
		
}

digita_rota(){

					dialog	--title "Configuracao de rota default" \
					--inputbox "Digite o endereco da interface de rede do proximo salto Endereco_IP" 0 0 2>/tmp/rota_salto.conf
					rota_salto=$(cat /tmp/rota_salto.conf)

				if [ $1 -eq 2 ]; then
					dialog	--title "Configuracao de rota estatica" \
					--inputbox "Digite o endereco da rede de destino Endereco_IP/(CIDR)" 0 0 2>/tmp/rota_ip.conf
					rota_ip=$(cat /tmp/rota_ip.conf)
				fi


	dialog	--title "Roteamento Estatico" \
		--menu "Escolha a Interface de saida da rota digitada " 0 0 0 \
	        ${interface[1]} "Interface de rede 1" \
	        ${interface[2]} "Interface de rede 2" \
	        ${interface[3]} "Interface de rede 3" \
	        ${interface[4]} "Interface de rede 4" \
		VOLTAR '' 2> /tmp/opcao
		opt=$(cat /tmp/opcao)
		
		case $opt in

			${interface[1]})
				rota_interface=${interface[1]}
				;;

			${interface[2]})
				rota_interface=${interface[2]}
				;;

			${interface[3]})
				rota_interface=${interface[3]}
				;;

			${interface[4]})
				rota_interface=${interface[4]}
				;;

			"VOLTAR")
				m_rota
				;;

			*)
				echo "Opcao Errada"
				;;
			esac
}

m_snaat(){

			dialog --title "Digite os enderecos fonte" \
				--backtitle "Pool de endereços da rede que se deseja realizar SNAT" \
				--inputbox "Digite ENDERECO_IP/(CIDR)" 0 0 2>/tmp/mux
			fonte=$(cat /tmp/mux)

			dialog --title "Digite o endereco de destino" \
				--backtitle "Endereço de rede que ira representar os endereços da pool" \
				--inputbox "Digite ENDERECO_IP" 0 0 2>/tmp/mux
			destino=$(cat /tmp/mux)

	dialog	--title "Interface SNAT" \
		--menu "Escolha a Interface de saida da rota digitada " 0 0 0 \
	        ${interface[1]} "Interface de rede 1" \
	        ${interface[2]} "Interface de rede 2" \
	        ${interface[3]} "Interface de rede 3" \
	        ${interface[4]} "Interface de rede 4" \
		VOLTAR '' 2> /tmp/opcao
		opt=$(cat /tmp/opcao)
		
		case $opt in

			${interface[1]})
				st_interface=${interface[1]}
				;;

			${interface[2]})
				st_interface=${interface[2]}
				;;

			${interface[3]})
				st_interface=${interface[3]}
				;;

			${interface[4]})
				st_interface=${interface[4]}
				;;

			"VOLTAR")
				config_if
				;;

			*)
				echo "Opcao Errada"
				;;
			esac

		iptables -t nat -F 
		iptables -t nat -A POSTROUTING -s $fonte -o $st_interface -j SNAT --to $destino

}

#Funcoes de configuracao automatica
function conf_automatica(){

dialog --title "Configuração do experimento com software Quagga" \
       --menu "Configure as interfaces e roteamento com protocolo OSPF " 0 0 0 \
    	"Endereco IP" "Configuracao de interface de rede utilizando quagga" \
    	"OSPF" "Roteamento OSPF utilizando quagga" \
		"VOLTAR" '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in

	  "Endereco IP")
	  c_zebra
        ;;

	  "OSPF")
	  conf_ospf	
        ;;

	"VOLTAR")
	voltar
	;;

	*)
	echo "Opcao Errada"
	;;
	
	esac


} #fim da funcao automatica

#Configuracao das interfaces de rede via quagga (zebra)

c_zebra(){

zebra=( - - - - - )

inf_zebra(){

			if [ "${interface[$1]}" == "lo" ] || [ "${interface[$1]}" == "inexistente" ];then
			zebra[$1]="rede local ou inexistente"	

			else
			dialog --title "Digite o endereço IP da interface ${interface[$1]}" \
				--backtitle "Configuração da interface de rede IPV4" \
				--inputbox "Digite ENDERECO_IP/(CIDR)" 0 0 2>/tmp/zebra
			zebra[$1]=$(cat /tmp/zebra)
			fi
}

m_zebra(){


		dialog --title "Configuração de zebra" \
			--menu "Digite as endereço da interface de rede" 0 0 0 \
			"Endereço da interface ${interface[1]}" "${zebra[1]}" \
			"Endereço da interface ${interface[2]}" "${zebra[2]}" \
			"Endereço da interface ${interface[3]}" "${zebra[3]}" \
			"Endereço da interface ${interface[4]}" "${zebra[4]}" \
			"Configurar zebra" "" \
		        VOLTAR '' 2> /tmp/opcao
			opt=$(cat /tmp/opcao)
			case $opt in
			
			"Endereço da interface ${interface[1]}")
			inf_zebra 1
			m_zebra $1
			;;
		"Endereço da interface ${interface[2]}")
			inf_zebra 2
			m_zebra $1
			;;
		"Endereço da interface ${interface[3]}")
			inf_zebra 3
			m_zebra $1
			;;
		"Endereço da interface ${interface[4]}")
			inf_zebra 4
			m_zebra $1
;;
        "Configurar zebra")
			conf_zebra $1
	;;
		"VOLTAR")
			mp_zebra 
;;
		*)
echo "opção errada"
;;

esac
}

conf_zebra(){

nome=$(hostname)

echo "
! -*- zebra -*-
!
hostname $nome
password admin 
enable password admin
log file /var/log/quagga/zebra.log
!
debug zebra events
debug zebra packet
!
interface lo
!
!" > /etc/quagga/zebra.conf
if [ $1 -eq 4 ]; then

echo "ip forwarding" >> /etc/quagga/zebra.conf
contador=1
until [ $contador -gt $numero ];do
	if [ "${zebra[$contador]}" == "-" ] || [ "${zebra[$contador]}" == "rede local ou inexistente" ];then
    echo 1 
	else
echo "!
interface ${interface[$contador]}
link-detect
ip address ${zebra[$contador]}
ipv6 nd suppress-ra
!" >> /etc/quagga/zebra.conf
    fi
let contador+=1
done

else
echo "ipv6 forwarding" >> /etc/quagga/zebra.conf
contador=1
until [ $contador -gt $numero ];do
	if [ "${zebra[$contador]}" == "-" ] || [ "${zebra[$contador]}" == "rede local ou inexistente" ];then
    echo 1 
	else
echo "!
interface ${interface[$contador]}
link-detect
no ipv6 nd suppress-ra
ipv6 nd ra-interval 10
ipv6 address ${zebra[$contador]}
!" >> /etc/quagga/zebra.conf
    fi
let contador+=1
done
fi

voltar

}

mp_zebra(){
	dialog --title "Configuracao de  intefaces via zebra" \
			--menu "Escolha o protocolo IP para configuracao" 0 0 0 \
			"Protocolo IPv4" "" \
			"Protocolo IPv6" "" \
            VOLTAR '' 2>/tmp/opcao
	        opt=$(cat /tmp/opcao)
			case $opt in

				"Protocolo IPv4")
					m_zebra 4
					;;
					"Protocolo IPv6") 
					m_zebra 6
						;;
					"VOLTAR") 
						voltar
						;;
				*)
					echo "fim de script"
					;;
			esac
}

mp_zebra

}

#Funcao do tayga-NAT64

function conf_NAT64(){

 dialog	--title "Configuracao Manual Tayga" \
		--menu "Insira os parametros de configuracao" 0 0 0 \
	        "Prefixo IPv6 de NAT64" "$PREFIX" \
	        "Pool de mapeamento IPv4" "$TAYGA_IPV4_POOL" \
	        "Endereço IPv4 do Tayga" "$TAYGA_IPV4ADDR" \
	        "Endereço da interface IPv4" "$ifacev4" \
	        "Endereço da interface IPv6" "$ifacev6" \
	        "Iniciar config. do NAT64" "" \
			"VOLTAR" '' 2> /tmp/opt
		opt=$(cat /tmp/opt)

case $opt in
			"Prefixo IPv6 de NAT64")
				dialog	--title "Prefixo NAT64" \
					--inputbox "Favor digitar o prefixo NAT64 com a máscara (/96) (ex.: 2001:db8:1:ffff::/96)" 0 0 2>/tmp/prefixnat64.conf
					PREFIX=$(cat /tmp/prefixnat64.conf)
					conf_NAT64
				;;

			"Pool de mapeamento IPv4")
				dialog	--title "Config. de pool NAT64" \
					--inputbox "Favor Digitar um Endereco IPv4 de rede com a máscara CIDR (ex.: 192.168.255.0/24)" 0 0 2>/tmp/poolnat64.conf
					 TAYGA_IPV4_POOL=$(cat /tmp/poolnat64.conf)
					conf_NAT64
				;;

			"Endereço IPv4 do Tayga")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor Digitar um Endereco IPv4 pertencente ao pool de endereços do NAT64 (ex.: 192.168.255.1)" 0 0 2>/tmp/ipv4nat64.conf
					TAYGA_IPV4ADDR=$(cat /tmp/ipv4nat64.conf)
					conf_NAT64
				;;

			"Endereço da interface IPv4")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor digitar o endereço da interface IPv4 do roteador COM a máscara (ex.: 192.168.0.200/24)" 0 0 2>/tmp/ifacev4.conf
					ifacev4=$(cat /tmp/ifacev4.conf)
					echo "${ifacev4%???}" > /tmp/v4nomask
					ipv4nomask=$(cat /tmp/v4nomask)
					conf_NAT64
				;;

			"Endereço da interface IPv6")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor digitar o endereço da interface IPv6 do roteador COM a máscara (ex.: 2001:db8:1::3/64)" 0 0 2>/tmp/ifacev6.conf
					ifacev6=$(cat /tmp/ifacev6.conf)
					echo "${ifacev6%???}" > /tmp/v6nomask
					ipv6nomask=$(cat /tmp/v6nomask)
					conf_NAT64
				;;

			"Iniciar config. do NAT64")
				dialog --yesno 'Deseja realizar SNAT para a rede externa?' 0 0
				doNAT=$?
				configIP
				configNAT64
				;;
			"VOLTAR")
				voltar
				;;
			esac
		}

 configIP(){

 	sysctl -w net.ipv6.conf.all.forwarding=1
	sysctl -w net.ipv4.ip_forward=1

 	# Interface IPv4 #####
 	sudo ip addr flush dev ${interface[2]}
	sudo ip link set ${interface[2]} up 
	sudo ip addr add $ifacev4 dev ${interface[2]}

	# Interface IPv6 #####
	sudo ip addr flush dev ${interface[1]}
	sudo ip link set ${interface[1]} up 
	sudo ip -6 addr add $ifacev6 dev ${interface[1]}
 }


 configNAT64(){

	DIR_TAYGA=$(find /home -type d -name tayga-0.9.2)

	cd $DIR_TAYGA

	./configure && make && make install

	mkdir -p /var/db/tayga

	echo "tun-device nat64
		ipv4-addr $TAYGA_IPV4ADDR
		prefix $PREFIX
		dynamic-pool $TAYGA_IPV4_POOL
		data-dir /var/db/tayga" > /usr/local/etc/tayga.conf

	tayga --mktun
	ip link set nat64 up
	ip addr add $ifacev4 dev nat64 
	ip addr add $ifacev6 dev nat64   
	ip route add $PREFIX dev nat64
	ip route add  $TAYGA_IPV4_POOL dev nat64
	
	iptables -F 
	
	if [ $doNAT = 0 ]; then
		iptables -t nat -F 
		iptables -t nat -A POSTROUTING -s $TAYGA_IPV4_POOL -o ${interface[2]} -j SNAT --to $ipv4nomask
	fi
	
	iptables -A FORWARD -i ${interface[2]} -o nat64 -m state --state RELATED,ESTABLISHED -j ACCEPT 
	iptables -A FORWARD -i nat64 -o ${interface[2]} -j ACCEPT
	tayga

	echo -e "\n************* Configuração NAT64 completa! *******************\n"
}

 PREFIX="-"
 TAYGA_IPV4ADDR="-"
 TAYGA_IPV4_POOL="-"
 ifacev6="-"
 ifacev4="-"


################### CONFIGURAÇÃO SERVIDOR DNS64 ##########################

function conf_DNS64(){

dialog	--title "Configuração DNS64" \
		--menu "Insira os parametros de configuração" 0 0 0 \
	        "Forwarder IPv4" "$v4Forwarder" \
 	        "Forwarder IPv6" "$v6Forwarder" \
 	        "Prefixo do NAT64" "$PREFIXNAT64" \
 	        "Endereço da interface IPv4" "$ifacev4" \
 	        "Rede IPv6 permitida" "$v6network" \
 	        "Iniciar config. do DNS64" "" \
			"VOLTAR" '' 2> /tmp/opt 
		opt=$(cat /tmp/opt)


	case $opt in
			"Forwarder IPv4")
				dialog	--title "Forwarder IPv4" \
					--inputbox "Favor digitar o Forwarder IPv4 (ex.: 8.8.8.8)" 0 0 2>/tmp/forwarderv4.conf
					v4Forwarder=$(cat /tmp/forwarderv4.conf)
			conf_DNS64		
				;;

			"Forwarder IPv6")
				dialog	--title "Forwarder IPv6" \
					--inputbox "Favor digitar o Forwarder IPv6 (ex.: 2001:4860:4860::8888)" 0 0 2>/tmp/forwarderv6.conf
					v6Forwarder=$(cat /tmp/forwarderv6.conf)
					conf_DNS64
				;;

			"Prefixo do NAT64")
				dialog	--title "Config.  de prefixo NAT64" \
					--inputbox "Favor digitar o prefixo utilizado pelo NAT64 (ex.: 2001:db8:1:ffff::/96)" 0 0 2>/tmp/prefixnat64.conf
					PREFIXNAT64=$(cat /tmp/prefixnat64.conf)
					conf_DNS64
				;;

			"Rede IPv6 permitida")
				dialog	--title "Config.  de prefixo NAT64" \
					--inputbox "Favor digitar o prefixo utilizado pelo NAT64 (ex.: 2001:db8::/64)" 0 0 2>/tmp/v6network.conf
					v6network=$(cat /tmp/v6network.conf)
					conf_DNS64
				;;

			"Endereço da interface IPv4")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor digitar o endereço da interface IPv4 do roteador COM a máscara (ex.: 192.168.0.200/24)" 0 0 2>/tmp/ifacev4.conf
					ifacev4=$(cat /tmp/ifacev4.conf)
					echo "${ifacev4%???}" > /tmp/v4nomask
					ipv4nomask=$(cat /tmp/v4nomask)
					conf_DNS64
				;;

			"Iniciar config. do DNS64")
				dialog --yesno 'Deseja realizar autenticação DNSSEC?' 0 0
				doDNSSEC=$?
				dialog --yesno 'Deseja que o DNS responda autoritativamente ao receber respostas NXDOMAIN?' 0 0
				doAUTORITATIVO=$?
				dialog --yesno 'Deseja que o DNS64 retorne apenas endereços IPv4? (prefixo + ipv4)' 0 0
				doEXCLUDE=$?
				write_config
				;;
			"VOLTAR")
				voltar
				;;
			esac
		}
write_config(){

	if [ $doDNSSEC = 0 ]; then
		
		doDNSSECyn="yes"
	
	else

		doDNSSECyn="no"

	fi

	if [ $doAUTORITATIVO = 0 ]; then
		
		doAUTORITATIVOyn="yes"
	
	else

		doAUTORITATIVOyn="no"

	fi

	if [ $doEXCLUDE = 0 ]; then
		
		doEXCLUDEyn="exlude { any; };"
	
	else

		doEXCLUDEyn="#exlude { any; };"

	fi

	echo  "options{
	
	directory \"/var/cache/bind\"
	
		forwarders {
			
			$v4Forwarder ;
			$v6Forwarder ;

		};


	dnssec-validation $doDNSSECyn ;

	auth-nxdomain $doAUTORITATIVOyn ;    
	
	listen-on-v6 { any; }; 
	
	allow-query { localnets; localhost; $v6network ; }; 
	
	allow-recursion { localnets; localhost; $v6network ; }; 
	
	dns64 $PREFIXNAT64 { 
	
	clients { any; }; 
	$doEXCLUDEyn

	};
	};" > /etc/bind/named.conf.options
	

	echo -e "\n\nFIM!!!!!!!!!\n\n"
}

v4Forwarder="-"
v6Forwarder="-"
PREFIXNAT64="-"
ifacev4="-"
ifacev6="-"
v6network="-"

##################################################################OSPF IP ##################################################
conf_ospf(){

rede=( - - - - - )
area=( - - - - - )
id= "-"

mp_ospf(){
	dialog --title "Configuracao de protocolo OSPF" \
			--menu "Escolha o protocolo IP para configuracao OSPF" 0 0 0 \
			"Protocolo IPv4" "" \
			"Protocolo IPv6" "" \
			"VOLTAR" '' 2>/tmp/opcao
	        opt=$(cat /tmp/opcao)
			case $opt in

				"Protocolo IPv4")
				rede=( - - - - - )
				area=( - - - - - )
				id= "-"
				ospf_menu 4	
					;;
					"Protocolo IPv6") 
					rede=( - - - - - )
					area=( - - - - - )
					id= "-"
					ospf_menu 6
						;;
					"VOLTAR") 
						voltar
						;;
				*)
					echo "fim de script"
					;;
			esac
}

ospf_menu(){

	dialog --title "Configuracao do protocolo OSPF" \
		--menu "Escolha a configuracao:" 0 0 0 \
	"Redes diretamente conectadas" "" \
	"Area ao que o dispositivo pertence" "" \
	"Id do dispositivo" "" \
	"Configurar OSPF" "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in

		"Redes diretamente conectadas")
		m_rede_ospf $1
			;;
		"Area ao que o dispositivo pertence")
		m_area_ospf $1
			;;
		"Id do dispositivo")
		m_id_ospfv6 $1
			;;
		"Configurar OSPF")
			if [ $1 -eq 4 ]; then
		conf_ospfv4
	else
		conf_ospfv6
			fi	
			;;
		"VOLTAR")
	    mp_ospf	
;;
		*)
echo "opção errada"
;;
	esac
}

m_id_ospfv6(){

			dialog --title "ID  do dispositivo}" \
				--backtitle "ID do dispositivo para configuracao do OSPF" \
				--inputbox " Exemplo de rede ID 0.0.0.1 " 0 0 2>/tmp/id
			id=$(cat /tmp/id)

	ospf_menu $1
}

conf_ospfv4(){
daemons 4
nome=$(hostname)

echo "
! -*- ospf -*-
!
log stdout
!
hostname $nome
password admin
log file /var/log/quagga/zebra.log
log stdout
!
debug ospf event
debug ospf packet all
!
interface lo
!
" > /etc/quagga/ospfd.conf

contador=1
until [ $contador -gt $numero ];do
	if [ "${rede[$contador]}" == "-" ] || [ "${rede[$contador]}" == "rede local ou inexistente" ];then
    echo 1 
	else
echo "!
interface ${interface[$contador]}
!
router ospf
network ${rede[$contador]} area ${area[$contador]}" >> /etc/quagga/ospfd.conf
    fi
let contador+=1
done

voltar

}

conf_ospfv6(){
daemons 6
nome=$(hostname)

echo "
!
hostname $nome
password admin
log stdout
service advanced-vty
!
debug ospf6 neighbor state
!
interface lo0
ipv6 ospf6 cost 1
ipv6 ospf6 hello-interval 10
ipv6 ospf6 dead-interval 40
ipv6 ospf6 retransmit-interval 5
ipv6 ospf6 priority 1
ipv6 ospf6 transmit-delay 1
ipv6 ospf6 instance-id 0
!
" > /etc/quagga/ospf6d.conf

contador=1
until [ $contador -gt $numero ];do
	if [ "${rede[$contador]}" == "-" ] || [ "${rede[$contador]}" == "rede local ou inexistente" ];then
    echo 1 
	else
echo "!
interface ${interface[$contador]}
!
router ospf6
router-id ${id}
redistribute static
redistribute connected
area  ${area[$contador]} range ${rede[$contador]}
interface ${interface[$contador]} area ${area[$contador]}
access-list access4 permit 127.0.0.1/32
!" >> /etc/quagga/ospf6d.conf
    fi
let contador+=1
done

echo "!
ipv6 access-list access6 permit 3ffe:501::/32
ipv6 access-list access6 permit 2001:200::/48
ipv6 access-list access6 permit ::1/128
!
ipv6 prefix-list test-prefix seq 1000 deny any
!
route-map static-ospf6 permit 10
match ipv6 address prefix-list test-prefix
set metric-type type-2
set metric 2000
!
line vty
access-class access4
ipv6 access-class access6
exec-timeout 0 0
!
" >> /etc/quagga/ospf6d.conf

voltar

}

rede_ospf(){


			if [ "${interface[$1]}" == "lo" ] || [ "${interface[$1]}" == "inexistente" ];then
			rede[$1]="rede local ou inexistente"	

			else
			dialog --title "Digite as redes diretamente conectadas a interface ${interface[$1]}" \
				--backtitle "Configuração OSPF " \
				--inputbox "Exemplo de rede 192.168.1.0/24 ou 2001:db8:1:1::/64" 0 0 2>/tmp/redes
			rede[$1]=$(cat /tmp/redes)
			fi
}

m_rede_ospf(){


		dialog --title "Configuração de redes OSPF" \
			--menu "Digite as redes diretamente conectadas as interfaces" 0 0 0 \
			"Rede diretamente conectada a interface ${interface[1]}" "${rede[1]}" \
			"Rede diretamente conectada a interface ${interface[2]}" "${rede[2]}" \
			"Rede diretamente conectada a interface ${interface[3]}" "${rede[3]}" \
			"Rede diretamente conectada a interface ${interface[4]}" "${rede[4]}" \
		        VOLTAR '' 2> /tmp/opcao
			opt=$(cat /tmp/opcao)
			case $opt in
			
			"Rede diretamente conectada a interface ${interface[1]}")
			rede_ospf 1
			m_rede_ospf $1
			;;
			"Rede diretamente conectada a interface ${interface[2]}")
			rede_ospf 2
			m_rede_ospf $1
			;;
			"Rede diretamente conectada a interface ${interface[3]}")
			rede_ospf 3
			m_rede_ospf $1
			;;
			"Rede diretamente conectada a interface ${interface[4]}")
			rede_ospf 4
			m_rede_ospf $1
			;;
		"VOLTAR")
	ospf_menu $1
;;
		*)
echo "opção errada"
;;

esac
}

area_ospf(){


			if [ "${interface[$1]}" == "lo" ] || [ "${interface[$1]}" == "inexistente" ];then
			area[$1]="rede local ou inexistente"	

			else
			dialog --title "Digite a area da interface ${interface[$1]}" \
				--backtitle "Configuração da area OSPF" \
				--inputbox "Exemplo de rede 0.0.0.0" 0 0 2>/tmp/area
			area[$1]=$(cat /tmp/area)
			fi

}

m_area_ospf(){


		dialog --title "Configuração de redes OSPF" \
			--menu "Digite a área OSPF onde estao conectadas as interfaces" 0 0 0 \
			"Area diretamente conectada a interface ${interface[1]}" "${area[1]}" \
			"Area diretamente conectada a interface ${interface[2]}" "${area[2]}" \
			"Area diretamente conectada a interface ${interface[3]}" "${area[3]}" \
			"Area diretamente conectada a interface ${interface[4]}" "${area[4]}" \
		        VOLTAR '' 2> /tmp/opcao
			opt=$(cat /tmp/opcao)
			case $opt in
			
				"Area diretamente conectada a interface ${interface[1]}")
			area_ospf 1
			m_area_ospf $1
			;;
				"Area diretamente conectada a interface ${interface[2]}")
			area_ospf 2
			m_area_ospf $1
			;;
			"Area diretamente conectada a interface ${interface[3]}")
			area_ospf 3
			m_area_ospf $1
			;;
			"Area diretamente conectada a interface ${interface[4]}")
			area_ospf 4
			m_area_ospf $1
			
;;
		"VOLTAR")
	ospf_menu $1
;;
		*)
echo "opção errada"
;;

esac
}

daemons(){

	if [ $1 -eq 6 ]; then
echo "
zebra=yes
bgpd=no
ospfd=no
ospf6d=yes
ripd=no
ripngd=no
isisd=no
" > /etc/quagga/daemons

else

echo "
zebra=yes
bgpd=no
ospfd=yes
ospf6d=no
ripd=no
ripngd=no
isisd=no
" > /etc/quagga/daemons

	fi
}

mp_ospf

}

#Criacao das  funcoes
function voltar(){
dialog	--title "Tela de Controle" \
	--menu "Escolha uma opcao:" 0 0 0 \
	"Configuracoes diversas" "Configuracao  estatica do roteamento e interfaces de rede" \
    "Quagga" "Configuracao das interfaces de rede e OSPF via Quagga" \
	"NAT64" "Configuração do tayga no host de desejado" \
	"DNS64" "Configuração do BIND no host desejado"  2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in
		"Configuracoes diversas")
			config_if
			;;
		"Quagga")
			conf_automatica	
			;;
		"NAT64")
			conf_NAT64
			;;
		"DNS64")
			conf_DNS64
			;;
		esac
}

#Menu Principal 
dialog	--title "Tela de Controle" \
	--menu "Escolha uma opcao:" 0 0 0 \
	"Configuracoes diversas" "Configuracao  estatica do roteamento e interfaces de rede" \
    "Quagga" "Configuracao das interfaces de rede e OSPF via Quagga" \
	"NAT64" "Configuração do tayga no host de desejado" \
	"DNS64" "Configuração do BIND no host desejado"  2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in
		"Configuracoes diversas")
			config_if
			;;
		"Quagga")
			conf_automatica	
			;;
		"NAT64")
			conf_NAT64
			;;
		"DNS64")
			conf_DNS64
			;;
		esac
