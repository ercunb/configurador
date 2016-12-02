# READ-ME

----------------x----------------------

Link para Download da VM com todas as ferramentas de rede.

https://1drv.ms/f/s!Ah8Q1rU90pW1biCsnrUZ3DxYvL4

Observação: CASO SEJA UTILIZADA OUTRA MÁQUINA VIRTUAL LINUX, FAZER O DOWNLOAD DAS FERRAMENTAS:

TAYGA, BIND9, DIALOG, BUILD-ESSENTIAL, IPTABLES.

Link pro Tayga 0.9.2: http://www.litech.org/tayga/tayga-0.9.2.tar.bz2

Para que o script seja corretamente utilizado, extrair a pasta tayga-0.9.2 em alguma pasta na /home.

-----------------x---------------------

Configurador de VMs Linux

De forma a facilitar a configuração das maquinas virtuais que compõem a topologia de
rede a ser utilizada, desenvolveu-se uma ferramenta utilizando a linguagem bash. Além
de bash, foi utilizado o recurso do pacote dialog, como pode ser visto na figura 3.1, onde
encontra-se o menu principal da ferramenta, que precisa ser instalado no ambiente Linux
para o devido funcionamento do script implementado.
Com exceção do pacote dialog, o script é composto por comandos nativos Linux, que
não precisam de instalação de pacotes adicionais e funcionam em ambiente de linha de
comando. A ferramenta tem como funções principais a configuração das interfaces de rede
em um host/roteador, a adição de rotas na tabela de roteamento, tanto IPv4 quanto IPv6
e realização de roteamento OSPF utilizando-se da ferramenta Quagga, que deve ser previamente
instalada para uso correto da função. Como a ferramente realiza comandos e altera
configurações da máquina GNU/Linux, ela deve ser executada em modo de super usuário.

![myimage-alt-tag](https://s16.postimg.org/dlbwkjyt1/dialog_menuprincipal.png)

Figura 3.1: Menu principal da ferramenta de configuração


--> Configuração da interface de rede

Utilizando-se a ferramenta proposta, existem 2 meios de se configurar interfaces de rede.
Uma das formas utiliza de comandos nativos do Linux para exercer tal função, e a outra
utiliza o software Quagga, que faz uso do software Zebra contido no próprio pacote.
Ao escolher a opção IP no primeiro menu dialog, figura 3.1, abre-se a opção de configuração
utilizando dos comandos nativos do sistema Linux, onde é possível escolher entre
configuração de interface em endereçamento IPv4 e IPv6. Ao escolher umas das duas opções,
escolhe-se a interface desejada para configuração e depois digita-se o endereço IP
desejado com a máscara de rede CIDR. Vide figura 3.2.

![myimage-alt-tag](https://s16.postimg.org/8legclt6d/dialog_ipestatico.png)

Figura 3.2: Menus da configuração de interface de rede


Em background, ao informar as opções pedidas pela ferramenta, são executados os comandos:
- Comando para limpar qualquer endereço previamente configurado na interface.

$ sudo ip addr flush dev "interface de rede"

- Comando para habilitar a interface, caso ela não esteja habilitada.

$ sudo ip link set "interface de rede" up

- Por fim, há a configuração propriamente dita da interface desejada com seu respectivo endereço IP.

$ sudo ip addr add "endereço IP" dev "interface de rede"

- Para endereçamento IPv6:

$ sudo ip -6 addr add "endereço IP" dev "interface de rede"

--> Roteamento estático

No dialog da figura 3.3, é possível escolher a opção de configuração de roteamento, onde
é possível adicionar rotas para redes com endereçamento IPv4 e IPv6. Escolhendo um dos
tipos de roteamento, é possível configurar tanto rotas para uma rede específica quanto um
rota default, como ilustra a figura 3.4. Para efetiva configuração de uma rota default, é
preciso informar o endereço de rede do próximo salto, assim como a interface de saída para
o endereço desejado.

![myimage-alt-tag](https://s16.postimg.org/vll3oxr05/dialog_estatico.png)

Figura 3.3: Menus da configuração de roteamento estático


![myimage-alt-tag](https://s16.postimg.org/mwxyhibcl/dialog_roteamentoestatico.png)

Figura 3.4: Menus da escolha do tipo de rota


Na configuração de uma rota default, a ferramenta executa para IPv4 o comando:

$ ip route add default via "IP do próximo salto" dev "interface de rede"

E para IPv6:

$ ip -6 route add default via "IP do próximo salto" dev "interface de rede"

No caso da adição de uma rota para uma rede desejada, deve-se informar o endereço
de rede da rota desejada, endereço da interface de rede do próximo salto e a interface
diretamente conectada a esse endereço.

Ao se adicionar uma rota para uma rede específica, é executado o comando:

$ ip route add "endereço IP da rede de destino" via \
"endereço IP do proximo salto" dev "interface de rede"

Para redes com endereçamento IPv6:

$ ip -6 route add "endereço IP da rede de destino" \
via "endereço IP do proximo salto" dev "interface de rede"

--> Configuração via Quagga

As configurações de roteamento e interface de rede podem ser efetuadas escolhendo a
segundo opção da tela dialog inicial, figura 3.5.

![myimage-alt-tag](https://s16.postimg.org/tyvw3peyd/dialog_quagga.png)

Figura 3.5: Menus da configuração do módulo Quagga


- Configuração de interface via Quagga

No menu dialog para a configuração das interfaces de rede, é necessário informar quais
interfaces devem ser configuradas e o endereço de rede de cada interface escolhida. Ao
se digitar as informações, o par endereço de rede e interface são usados para alterar os
arquivos de configuração zebra.conf do Zebra, que é o modulo do quagga responsável pela
configuração das interfaces de rede, aquivo esse localizado no diretório:

/etc/quagga

Roteamento dinâmico com protocolo OSPF

Caso selecione-se a opção de configuração de roteamento OSPF, serão configurados no
quagga os mesmos pré requisitos que roteadores de mercado exigem para a configuração
do protocolo OSPF, ilustrados na figura 3.6. É preciso informar as redes diretamente
conectadas, as interfaces que estão conectadas as redes informadas e a área que cada rede
pertence. No caso da escolha do OSPF em endereçamento IPv6, também é preciso informar
a identidade da maquina ou dispositivo que está sendo utilizado.

![myimage-alt-tag](https://s16.postimg.org/4vetjphbp/dialog_roteamentoquagga.png)

Figura 3.6: Menus da configuração do roteamento OSPF via Quagga


Tendo informado todos os parâmetros necessários para o OSPF com o protocolo IPv4, as
configurações desejadas são escritas no aquivo ospfd.conf. Para o OSPFv6, as configurações
são escritas no arquivo ospfd6.conf.

Ambos os arquivos de configuração estão localizados na pasta de arquivos de configuração
quagga:

/etc/quagga

--> NAT64

A ferramenta proposta efetua o NAT64 utilizando o software Tayga. Ao selecionar a
opção de configuração NAT64, é aberto o dialog ilustrado na figura 3.7, onde é preciso
informar os parâmetros pedidos. O prefixo IPv6 é necessário para a efetiva tradução de um
endereço de rede IPv4 em IPv6. A pool IPv4 é necessária para traduzir um endereço IPv6
em um endereço IPv4 válido. Por fim, um endereço pertencente a pool IPv4 deve ser usado
para endereçar o servidor Tayga, para fins de respostas a requisições e respostas ICMP.

![myimage-alt-tag](https://s16.postimg.org/9q8ihzfn9/dialog_NAT64.png)

Figura 3.7: Menus da configuração do NAT64


No menu do NAT64, também são requeridos os endereços das interfaces de rede IPv4 e
IPv6, logo, para a correta configuração do servidor Tayga, e consequentemente do serviço de
tradução, a máquina usada deve possuir ao menos duas interfaces de rede, uma conectada
à rede IPv6 e outra à internet ou qualquer outra rede que possua endereçamento IPv4.
Ao efetuar-se a configuração do NAT64, os parâmetros informados são usados para
modificar o aquivo de configuração Tayga, tayga.conf, localizado no diretório:

/usr/local/etc/

Ao realizar-se a configuração do NAT64, o script também verifica se é necessária a realização
de SNAT via iptables no host, e em caso positivo, este procedimento é realizado
com as seguintes definições:

$ iptables -t nat -A POSTROUTING -s "Pool de endereços IPv4 do Tayga" -o "interface de rede" -j SNAT --to "Endereço da interface IPv4"

Dessa forma, após a tradução, todos os pacotes que sairão para a rede externa terão o
mesmo endereço IPv4 da interface do roteador, que caso tenha sido atribuído por algum
servidor DHCP será prontamente reconhecido e roteado sem necessidade de configurações
adicionais em outros componentes de rede.

DNS64

O DNS64 é implementado utilizando o BIND9, e para o seu funcionamento em conjunto
com o NAT64, é preciso informar o mesmo prefixo IPv6 utilizado na configuração do Tayga,
figura 3.8. De forma a aumentar a segurança do servidor, também é preciso informar as
redes IPv6 que tem permissão para consultas DNS. Deve-se também informar os endereços
IP dos forwarders IPv4 e IPv6 utilizados para consultas DNS a servidores autoritativos
externos.

![myimage-alt-tag](https://s16.postimg.org/6ea7oonw5/dialog_DNS64.png)

Figura 3.8: Menus da configuração do DNS64


Ao habilitar-se a configuração do DNS64, quarta opção do menu da figura 3.1, ainda é
possível autorizar ou não a habilitação de DNSSEC, e se o DNS irá responder autoritativamente
ao receber respostas NXDOMAIN. Outra funcionalidade extra é a autorização para
que o DNS64 retorne apenas endereços IPv4 e traduza-os, na forma:

PREFIXO + ENDEREÇO IPv4

Após informados todos os parâmetros, esses são usados para alterar o aquivo de configuração
BIND9, named.conf.options, localizado no diretório:

/etc/bind/




