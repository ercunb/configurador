# configurador
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

![myimage-alt-tag](url-to-image)

--> Configuração da interface de rede

Utilizando-se a ferramenta proposta, existem 2 meios de se configurar interfaces de rede.
Uma das formas utiliza de comandos nativos do Linux para exercer tal função, e a outra
utiliza o software Quagga, que faz uso do software Zebra contido no próprio pacote.
Ao escolher a opção IP no primeiro menu dialog, figura 3.1, abre-se a opção de configuração
utilizando dos comandos nativos do sistema Linux, onde é possível escolher entre
configuração de interface em endereçamento IPv4 e IPv6. Ao escolher umas das duas opções,
escolhe-se a interface desejada para configuração e depois digita-se o endereço IP
desejado com a máscara de rede CIDR. Vide figura 3.2.

Em background, ao informar as opções pedidas pela ferramenta, são executados os comandos:
- Comando para limpar qualquer endereço previamente configurado na interface.

$ sudo ip addr flush dev "interface de rede"

- Comando para habilitar a interface, caso ela não esteja habilitada.

$ sudo ip link set "interface de rede" up

- Por fim, há a configuração propriamente dita da interface desejada com seu respectivo
endereço IP.

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
Na configuração de uma rota default, a ferramenta executa para IPv4 o comando:

#ip route add default via "IP do próximo salto" dev "interface de rede"

E para IPv6:

