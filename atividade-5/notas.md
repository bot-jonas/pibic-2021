## TCC - Jhenifer
### Resumo
Maximização da taxa total de transferência em um sistema WPCN (Wireless Powered Communication Network) que empreaga NOMA (Non-Orthogonal Multiple Access), estipulando uma taxa mínima de transmissão de dados para garantir QoS.

Dois estágios:
 - Energy Harvesting: Os terminais móveis têm suas baterias carregadas.
 - Transmissão de dados do usuário para o ponto de acesso (Uplink).

 Construção de heurísticas para a redução do custo computacional utilizado no problema de otimização.

### 2 - Tecnologias Promissoras para 5G e B5G
NOMA: Usuários usam os mesmos recursos de largura de banda simultaneamente.

Exemplo de downlink:
	- NOMA: Usuários com maior ganho de canal devem subtrair os sinais dos usuários com menor ganho (SIC). Os usuários com ganho menor não realizam SIC e sofrem interferência do sinal mais forte.
	- OMA: Os usuários não usam toda a banda simultaneamente e recebem os sinais de maneira direta.

Vantagens NOMA:
	- Eficiência espectral (Exemplo abaixo) e suporte a conectividade massiva.
	- "um usuário com dados de elevada prioridade tem
	ganhos de canal ruins e neste sistema deseja-se garantir justiça/equidade entre as taxas de dados
	obtidas pelos usuários. Com o uso de OMA, é forçoso que um dos recursos de largura de banda
	seja utilizado apenas por esse usuário mencionado. Com o uso de NOMA, todos os usuários
	utilizam os mesmos recursos de largura de banda ao mesmo tempo."

SIC:
	- Successive Interference Cancellation, algoritmo utilizado para decodificação de sinais que chegam simultaneamente em um receptor.
	- Downlink: Melhor canal faz o SIC
	- Uplink: Melhor canal é decodificado primeiro considerando os outros como interferência, depois este sinal é subtraido e o processo é repetido novamente até o último usuário.

Colheita de Energia:
	- ...Carregamento sem fio das baterias...
	- Fontes de enrgia naturais não são consideradas neste TCC

### 4 - Otimização de um Sistema WPCN
Uplink
Valores:
	- J: Número de terminais
	- N: Número de slots de tempo
	- n^e: Número de slots para transferência de energia
	- n^i: Número de slots para transmissão de informação
	- n^e + n^i = N > n^e > 0
	- T^s: Duração de um slot de tempo
	- P: Potência de transmissão (constante) do AP
	- E_{j,n^e} = P*η*g_j*n^e*T^s : Energia coletada na primeira fase
	- P_{j,n^e} = E_{j,n^e}/(T^s*(N-n^e)) ; Potência de transmissão da segunda fase
	- ρ_p : p-ésima permutação de {1, ..., J}
	- ρ_{p,i} : i-ésimo elemento da permutação ρ_p
	- r_{ρ_{p,i},n^e p} = \frac{B*n^i}{N}*log2(1 + )
	- r_{\rho_{p, i},n^e,p}=\frac{B\cdot n^i}{N}\log_2\left(1+\dfrac{P_{\rho_{p,i},n^e} \cdot g_{\rho_{p,i}}}{\sigma^2+\sum\limits_{k=i+1}^{J}{P_{\rho_{p,k},n^e} \cdot g_{\rho_{p,k}}}}\right) ***
	- M: J! número total de permutações

Problema:
	Vars: bin x_{n^e, p}
	Func: max_{x_{n^e, p}}{(n^e, p, j) in [1, N-1][1, M][1, J] (r_{j,n^e,p} * x_{n^e,p})}
	Cons: [
		Restrição de taxa: (n^e, p) in [1, N-1][1, M] (r_{j,n^e,p} * x_{j,n^e,p}) >= R_j, for all j in [1, J],
		Apenas um slot e uma permutação: (n^e, p) in [1, N-1][1, M] (x_{j,n^e,p}) = 1
	]

### 6 - Heurísticas Propostas
Valor fixo de n^e -> Taxa total independe da permutação
Proof: As Trivial as telescoping series...

Heurística 1: Permutação encontrada a partir de prioridades, prioridade de um usuário definida como a razão entre a taxa obtida no pior caso e o valor da taxa para atingir QoS.

Heurística 2: Heurística 1 em ...for(n^e--)...

## SBrT 2020 - Jhenifer
...Basicamente o TCC resumido e em inglês...

## Livro da Andrea Goldsmith cap. 10 (10.1, 10.2, 10.4)
MIMO - Sistemas com múltiplas antenas no transmissor e no recepetor

### 10.1 - Narrowband MIMO Model
Y[Mr][1] = H[Mr][Mt]*X[Mt][1] + n[Mr][1]

### 10.2 - Parallel Decomposition of the MIMO Channel
- Multiplexing Gain
	- Decompose the channel in parallel independent channels

ỹ = U^h(Hx + n)
ỹ = U^h(UΣVx + n)
ỹ = U^h(UΣVV^hx~ + n)
ỹ = Σx~ + U^h*n

### 10.4 - MIMO Diversity Gain: Beamforming
V and U are column vectors (v and u)
y = u^*Hvx + u^*n

## Rate-Splitting Unifying SDMA, OMA, NOMA, and Multicasting in MISOBroadcast Channel A Simple Two-User Rate Analysis
- muzukashii
- ...Dividir conjunto de mensagens em partes comuns e específicas. Quando chegarem no receptor, (SIC) a parte comum é decodificada considerando as partes específicas como interferência depois é removida da mensagem original...

...

## Rate-Splitting Multiple Access A New Frontier for the PHY Layer of 6G
- ... A mesma coisa do artigo anterior, só que com uma introdução mais amigável ...
...

## Sum-RateMaximization of Uplink Rate Splitting Multiple Access (RSMA) Communication

... Descrição como as anteriores e análise de um problema semelhante ao do TCC ...