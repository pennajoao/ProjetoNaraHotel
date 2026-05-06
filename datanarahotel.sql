
CREATE DATABASE data_nara_hoteis;
USE data_nara_hoteis;

SET GLOBAL local_infile = 1;

CREATE TABLE hoteis (
    id_hotel   INT          PRIMARY KEY,
    nome_hotel VARCHAR(100),
    cidade     VARCHAR(100),
    estado     VARCHAR(2),
    categoria  VARCHAR(50),
    n_quartos  INT
);

LOAD DATA INFILE 'C:/Users/matheus.rsoares/Desktop/hoteis.csv'
INTO TABLE hoteis
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_hotel, nome_hotel, cidade, estado, categoria, n_quartos);

CREATE TABLE quartos (
    id_quarto   VARCHAR(10)  PRIMARY KEY,
    id_hotel    INT,
    tipo_quarto VARCHAR(50),
    capacidade  INT,
    valor_base  DECIMAL(10,2),
    andar       INT,
    vista       VARCHAR(50),
    FOREIGN KEY (id_hotel) REFERENCES hoteis(id_hotel)
);

LOAD DATA INFILE 'C:/Users/matheus.rsoares/Desktop/quartos.csv'
INTO TABLE quartos
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_quarto, id_hotel, tipo_quarto, capacidade, valor_base, andar, vista); 

CREATE TABLE hospedes (
    id_hospede      INT          PRIMARY KEY,
    nome            VARCHAR(150),
    email           VARCHAR(150),
    telefone        VARCHAR(20),
    cidade_origem   VARCHAR(100),
    estado          VARCHAR(2),
    data_nascimento DATE,
    genero          VARCHAR(10)
);

LOAD DATA INFILE 'C:/Users/matheus.rsoares/Desktop/hospedes.csv'
INTO TABLE hospedes
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_hospede, nome, email, telefone, cidade_origem, estado, data_nascimento, genero);


CREATE TABLE reservas (
    id_reserva     INT          PRIMARY KEY,
    id_hospede     INT,
    id_quarto      VARCHAR(10),
    id_hotel       INT,
    data_checkin   DATE,
    data_checkout  DATE,
    canal_reserva  VARCHAR(50),
    valor_diaria   DECIMAL(10,2),
    status_reserva VARCHAR(30),
    data_reserva   DATE,
    FOREIGN KEY (id_hospede) REFERENCES hospedes(id_hospede),
    FOREIGN KEY (id_quarto)  REFERENCES quartos(id_quarto),
    FOREIGN KEY (id_hotel)   REFERENCES hoteis(id_hotel)
);

LOAD DATA INFILE 'C:/Users/matheus.rsoares/Desktop/reservas.csv'
INTO TABLE reservas
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_reserva, id_hospede, id_quarto, id_hotel, data_checkin, data_checkout, canal_reserva, valor_diaria, status_reserva, data_reserva);

CREATE TABLE avaliacoes (
    id_avaliacao         INT          PRIMARY KEY,
    id_reserva           INT,
    nota_geral           DECIMAL(4,2),
    nota_limpeza         DECIMAL(4,2),
    nota_atendimento     DECIMAL(4,2),
    nota_custo_beneficio DECIMAL(4,2),
    comentario           TEXT,
    data_avaliacao       DATE,
    FOREIGN KEY (id_reserva) REFERENCES reservas(id_reserva)
);

LOAD DATA INFILE 'C:/Users/matheus.rsoares/Desktop/avaliacoes.csv'
INTO TABLE avaliacoes
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_avaliacao, id_reserva, nota_geral, nota_limpeza, nota_atendimento, nota_custo_beneficio, comentario, data_avaliacao);


SELECT * FROM avaliacoes
