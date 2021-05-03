Base:
	- Process description
	- Math description
	- A math problem

## NOMA
- Acesso múltiplo não ortogonal
	- Esquema de acesso múltiplo onde os usuários usam os mesmos recursos de largura de banda simultaneamente
	- fig1 - NOMA & OMA

- SIC
	- Utilizado para resolver o problema das interferências
	- fig2 - SIC no downlink e uplink

- Sistema WPCN
	- Cenário de uplink com colheita de energia
	- Quadros são divididos em um número inteiro de intervalos
	- Duas fases: Colheita de energia e transmissão de informações

	- conjunto de usuários J = {1, ..., J}
	- número de intervalos em um quadro: N
	- número de intervalos da primeira fase: 0 < n^e < N
	- número de intervalos da primeira fase: 0 < n^i < N
	- n1 + n2 = N
	- duraçaõ de um intevalo: T^s

	- Energia adquirida na primeira fase: E_j_n^e = P.\eta.g_j.n^e.T^s
	- Potência de transmissão na segunda fase: P_j_n^e = E_j_n^e/(N - n^e)

	- Cálculo da taxa de transferência
	- \rho_p = p-ésimo elemento do conjunto das permutações dos usuários
	- \rho_p_i = i-ésimo elemento de \rho_p

	- \rho_p_i = B.n^i/N log2(1 + SINR) ... write this shit

- Problema de otimização
	- Maximizar a taxa total escolhendo um valor de n^e (para cada usuário) e uma permutação, problema muito difícil
	- Se n^e é fixo para todos os usuários então a taxa total independe da permutação (apresente a prova...)
	- Heuristica:
		- Escolher o n^e que maximiza a taxa total
		- Calcular a prioridade dos usuários com esse valor usando a razão entre a taxa que se obteria se esse usuário fosse o primeiro a ser decodificado (máxima interferência) e a taxa requisitada
		- Verifique se a soluçao é válida
		- Se não é válida, então remova este valor e repita...
		- Adicione figuras e fórmulas

## MIMO
- Sistemas com múltiplas antenas no transmissor e no recepetor
- Permite ganhos coisados

- Modelo
	- y = Hx + n
	mostre a imagem das antenas

	- Decomposição paralela
	- SVD: H = USV

	x" dados originais
	x = V'x" dados que serão transmitidos
	y dados que chegam
	y" dados decodificados
	y" = U'(Hx+n) = U'USVV'x" + U'n = Sx" + n"

- Beamforming
	- y = u'Hvx + u'n (u e v colunas -> diversity gain)
	- adicione figuras e fórmulas

## RS
- Uses the MIMO
- Divide o conjunto de mensagens em partes comuns e privadas. 
Codifica as partes comuns em apenas uma mensagem. Pré-codificadas para usar MIMO. Quando chegarem no receptor, (SIC) a parte comum é decodificada considerando as partes privadas como interferência e depois é removida da mensagem original.

- Cenário:
	- M antenas trasmitem para K usuários com apenas uma antena
	- Wk = Wc,k + Wp,k
	- Wc,k -> Wc -> sc
	- Wp,k -> sk
	- x = pcsc + sum(pksk)
	- yk = hkx + nk

	- Executes SIC
	- primeiro c, depois k

- Dependendo de como as mensagens são divididas podem se atingir outros esquemas, como NOMA, OMA, ...

- Sum Rate Analisys in RS Unifying...