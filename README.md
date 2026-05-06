# 🏨 Nara Hotéis — Análise de Dados

**Python · MySQL · Power BI**  
Fortaleza · Recife · Salvador · Rio de Janeiro · São Paulo  
Período: 2023 – 2025

---

## 📋 Contexto do Projeto

A Nara Hotéis é uma rede hoteleira brasileira com cinco unidades em destinos estratégicos do país. As decisões da diretoria ainda eram tomadas por percepção, sem dados estruturados.

O objetivo deste projeto foi transformar o histórico operacional de 2 anos em informação confiável, entregando visão analítica sobre reservas, receita, satisfação e overbooking.

---

## 📁 Estrutura dos Arquivos

```
├── hoteis.csv                  # Dados cadastrais dos 5 hotéis
├── quartos.csv                 # Catálogo de quartos por hotel
├── hospedes.csv                # Cadastro de hóspedes
├── reservas.csv                # Histórico de reservas 2023–2024
├── avaliacoes.csv              # Avaliações dos hóspedes
├── reservas_2025.csv           # Novas reservas (jan–out 2025)
├── avaliacoes_2025.csv         # Novas avaliações (2025)
├── Projeto_Nara_2_0.ipynb      # Notebook Python com análise completa
├── datanarahotel.sql           # Script de criação do banco MySQL
└── consultas_datanara.sql      # Consultas analíticas MySQL
```

---

## Entrega 1 — Python

### Bibliotecas utilizadas
- `pandas` — manipulação e limpeza dos dados
- `numpy` — cálculos estatísticos
- `matplotlib` — visualizações em painel com subplots

### Limpeza de Dados

**hoteis.csv**
- Categoria `6 estrelas` corrigida para `5 estrelas`
- Padronização de nomes de cidades e siglas de estados

**quartos.csv**
- Tipo `Standart` corrigido para `Standard`
- Removidos registros com capacidade zero ou negativa
- Valores base nulos preenchidos com a mediana do mesmo tipo de quarto no mesmo hotel
- Removido registro vinculado ao hotel 9, que não existe na base de hotéis

**hospedes.csv**
- Nomes padronizados com `.str.title()`
- Gênero padronizado para `M` e `F`
- IDs duplicados removidos mantendo o primeiro registro
- Estados inconsistentes corrigidos (`'rio de janeiro'` → `'RJ'`, `'RRJ'` → `'RJ'`)

**reservas.csv**
- Datas convertidas para o tipo `datetime`
- Removidos registros com cronologia inválida (checkout antes do checkin, ou reserva após o checkin)
- Removidos valores de diária nulos ou negativos
- Status padronizado (`'Cancelado'` → `'Cancelada'`)
- Canais padronizados (`'Booking.Com'` → `'Booking.com'`, `'Agencia De Viagem'` → `'Agência de Viagem'`)
- Canais nulos preenchidos com `'Não informado'`
- Reservas órfãs removidas (hóspede inexistente na base)

**avaliacoes.csv**
- Data de avaliação convertida para `datetime`
- Notas convertidas para numérico; valores não numéricos viram nulo
- Notas fora do domínio 0–10 removidas
- Avaliações vinculadas apenas a reservas com status `Confirmada`
- Avaliações com data anterior ao checkout removidas

### Incorporação dos dados de 2025
Os arquivos `reservas_2025.csv` e `avaliacoes_2025.csv` são concatenados automaticamente à base original caso estejam presentes na pasta:

```python
try:
    df_res_2025 = pd.read_csv('reservas_2025.csv')
    df_aval_2025 = pd.read_csv('avaliacoes_2025.csv')
    df_reservas = pd.concat([df_reservas, df_res_2025], ignore_index=True)
    df_avaliacoes = pd.concat([df_avaliacoes, df_aval_2025], ignore_index=True)
except FileNotFoundError:
    pass
```

### Análises realizadas

| # | Análise | Método |
|---|---------|--------|
| 01 | Valor típico das diárias | Comparação entre média e mediana |
| 02 | Valores atípicos | IQR — limite superior = Q3 + 1.5×IQR |
| 03 | Volume mensal de reservas confirmadas | Agrupamento por hotel e mês |
| 04 | Faixa de preço por tipo de quarto | Distribuição por categoria |
| 05 | Ticket médio por canal de vendas | Média de `valor_diaria` por canal |
| 06 | Taxa de cancelamento por canal | Proporção de canceladas sobre o total |
| 07 | Overbooking por hotel e período | Contagem de status `Overbooking` |
| 08 | Estimativa de receita perdida | `valor_diaria × dias_estadia` para canceladas e no-shows |

### Painel de visualizações
Os resultados são apresentados em um painel único com subplots gerado via `matplotlib`:
- Evolução mensal de reservas confirmadas por hotel
- Ticket médio por canal de vendas
- Taxa de cancelamento por canal
- Estimativa de receita perdida por hotel
- Resumo analítico com principais indicadores

---

## Entrega 2 — MySQL

### Modelagem do Banco de Dados

O banco `data_nara_hoteis` segue o modelo **fato–dimensão**:

- **Tabelas dimensão:** `hoteis`, `quartos`, `hospedes`
- **Tabela fato principal:** `reservas`
- **Tabela fato secundária:** `avaliacoes`

### Diagrama de Relacionamentos

```
hoteis ──────┬──── quartos
             │         │
             └──── reservas ──── avaliacoes
                       │
                   hospedes
```

### Chaves Estrangeiras

| Tabela | Coluna | Referência |
|--------|--------|------------|
| quartos | id_hotel | hoteis(id_hotel) |
| reservas | id_hospede | hospedes(id_hospede) |
| reservas | id_quarto | quartos(id_quarto) |
| reservas | id_hotel | hoteis(id_hotel) |
| avaliacoes | id_reserva | reservas(id_reserva) |

### Consultas Analíticas

**C1 — Receita por unidade**  
Hotéis ordenados pela maior receita total, considerando apenas reservas confirmadas.

**C2 — Hóspedes de alto valor**  
Reservas confirmadas com maior valor de diária, exibindo nome do hóspede, hotel e tipo de quarto.

**C3 — Hóspedes sem avaliação**  
Hóspedes que realizaram estadias confirmadas mas nunca deixaram avaliação, usando `LEFT JOIN` + `IS NULL`.

**C4 — Canais com mais reservas**  
Volume de reservas, receita total e diária média agrupados por canal.

**C5 — Overbooking por mês/hotel**  
Contagem de reservas com status `Overbooking` agrupadas por hotel e mês via `DATE_FORMAT`.

**C6 — Cancelamentos com menos de 7 dias de antecedência**  
Reservas canceladas onde `DATEDIFF(data_checkin, data_reserva) < 7`, com detalhamento do hóspede, hotel, quarto e canal.

**C7 — Hóspedes com histórico de no-show**  
Listagem detalhada de todos os registros com status `No-show`, ordenados por hóspede.

---

## Entrega 3 — Power BI

Relatório executivo com navegação por hotel e período, implementado com medidas DAX.

### Tabela Calendário (obrigatória para inteligência de tempo)
```dax
dCalendario = CALENDAR(MIN(reservas[data_checkin]), MAX(reservas[data_checkin]))
```

### Medidas DAX

**Receita Total**
```dax
Receita Total =
SUMX(FILTER(reservas, reservas[status_reserva] = "Confirmada"), reservas[valor_diaria])
```

**Taxa de Ocupação**
```dax
Taxa de Ocupação =
DIVIDE(
    COUNTROWS(FILTER(reservas, reservas[status_reserva] = "Confirmada")),
    COUNTROWS(quartos)
) * 100
```

**RevPAR** (Receita por quarto disponível)
```dax
RevPAR =
DIVIDE(
    SUMX(FILTER(reservas, reservas[status_reserva] = "Confirmada"), reservas[valor_diaria]),
    COUNTROWS(quartos)
)
```

**Variação vs. Mês Anterior**
```dax
Variação Mês Anterior =
VAR ReceitaAtual = [Receita Total]
VAR ReceitaMesAnterior = CALCULATE([Receita Total], DATEADD(dCalendario[Date], -1, MONTH))
RETURN DIVIDE(ReceitaAtual - ReceitaMesAnterior, ReceitaMesAnterior) * 100
```

**Variação vs. Mesmo Mês Ano Anterior**
```dax
Variação Mesmo Mês Ano Anterior =
VAR ReceitaAtual = [Receita Total]
VAR ReceitaAnoAnterior = CALCULATE([Receita Total], SAMEPERIODLASTYEAR(dCalendario[Date]))
RETURN DIVIDE(ReceitaAtual - ReceitaAnoAnterior, ReceitaAnoAnterior) * 100
```

**Índice de Satisfação**
```dax
Índice de Satisfação = AVERAGE(avaliacoes[nota_geral])
```

**Total Overbooking**
```dax
Total Overbooking =
COUNTROWS(FILTER(reservas, reservas[status_reserva] = "Overbooking"))
```

**Taxa de Cancelamento**
```dax
Taxa de Cancelamento =
DIVIDE(
    CALCULATE(COUNTROWS(reservas), reservas[status_reserva] = "Cancelada"),
    COUNTROWS(reservas)
) * 100
```

**Receita Perdida (Cancelamentos + No-show)**
```dax
Receita Perdida =
SUMX(
    FILTER(reservas, reservas[status_reserva] IN {"Cancelada", "No-show"}),
    reservas[valor_diaria]
)
```

---

## 🛠️ Tecnologias Utilizadas

- **Python 3** — pandas, numpy, matplotlib
- **MySQL / MariaDB** — modelagem relacional, LOAD DATA INFILE, JOINs, funções de data
- **Power BI** — DAX, inteligência de tempo, relatório executivo interativo

