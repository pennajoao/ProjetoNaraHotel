USE data_nara_hoteis;

-- C1 — Receita por unidade - Quais hotéis geram maior receita total no período?

SELECT
    hoteis.id_hotel,
    hoteis.nome_hotel,
    hoteis.cidade,
    hoteis.estado,
    COUNT(reservas.id_reserva)           AS total_reservas,
    ROUND(SUM(reservas.valor_diaria), 2) AS receita_total
FROM reservas
JOIN hoteis ON reservas.id_hotel = hoteis.id_hotel
WHERE reservas.status_reserva = 'Confirmada'
GROUP BY hoteis.id_hotel, hoteis.nome_hotel, hoteis.cidade, hoteis.estado
ORDER BY receita_total DESC; 

-- C2 — Hóspedes de alto valor - Reservas confirmadas com diária elevada — nome, hotel e tipo de quarto 

SELECT
    hospedes.nome                AS hospede,
    hoteis.nome_hotel,
    quartos.tipo_quarto,
    reservas.valor_diaria,
    reservas.data_checkin,
    reservas.data_checkout
FROM reservas
JOIN hospedes ON reservas.id_hospede = hospedes.id_hospede
JOIN hoteis   ON reservas.id_hotel   = hoteis.id_hotel
JOIN quartos  ON reservas.id_quarto  = quartos.id_quarto
WHERE reservas.status_reserva = 'Confirmada'
ORDER BY reservas.valor_diaria DESC
LIMIT 20;

-- C3 — Hóspedes sem avaliação - Quem realizou estadias mas nunca deixou uma avaliação?

SELECT
    hospedes.id_hospede,
    hospedes.nome,
    hospedes.email,
    COUNT(reservas.id_reserva) AS total_reservas
FROM hospedes
JOIN reservas        ON hospedes.id_hospede  = reservas.id_hospede
LEFT JOIN avaliacoes ON reservas.id_reserva  = avaliacoes.id_reserva
WHERE reservas.status_reserva = 'Confirmada'
AND avaliacoes.id_avaliacao IS NULL
GROUP BY hospedes.id_hospede, hospedes.nome, hospedes.email
ORDER BY total_reservas DESC;

-- C4 — Canais com mais reservas - Quais canais concentram o maior volume de reservas?

SELECT
    canal_reserva,
    COUNT(id_reserva)           AS total_reservas,
    ROUND(SUM(valor_diaria), 2) AS receita_total,
    ROUND(AVG(valor_diaria), 2) AS diaria_media
FROM reservas
GROUP BY canal_reserva
ORDER BY total_reservas DESC;

-- C5 — Overbooking por mês/hotel - Onde e quando o overbooking foi mais frequente?

SELECT
    hoteis.nome_hotel,
    DATE_FORMAT(reservas.data_checkin, '%Y-%m') AS mes,
    COUNT(reservas.id_reserva)                  AS total_reservas
FROM reservas
JOIN hoteis ON reservas.id_hotel = hoteis.id_hotel
GROUP BY hoteis.nome_hotel, mes
ORDER BY total_reservas DESC;

-- C6 — Reservas canceladas com menos de 7 dias de antecedência - Identificando o hotel e o canal de origem

SELECT
    reservas.id_reserva,
    hospedes.nome                                          AS hospede,
    hospedes.email,
    hoteis.nome_hotel,
    quartos.tipo_quarto,
    reservas.canal_reserva,
    reservas.valor_diaria,
    reservas.data_reserva,
    reservas.data_checkin,
    DATEDIFF(reservas.data_checkin, reservas.data_reserva) AS dias_antecedencia
FROM reservas
JOIN hospedes ON reservas.id_hospede = hospedes.id_hospede
JOIN hoteis   ON reservas.id_hotel   = hoteis.id_hotel
JOIN quartos  ON reservas.id_quarto  = quartos.id_quarto
WHERE reservas.status_reserva = 'Cancelada'
AND DATEDIFF(reservas.data_checkin, reservas.data_reserva) < 7
ORDER BY dias_antecedencia ASC;

-- C7 — Hóspedes com maior histórico de no-show 

SELECT
    hospedes.id_hospede,
    hospedes.nome,
    hospedes.email,
    COUNT(reservas.id_reserva) AS total_no_show
FROM hospedes
JOIN reservas ON hospedes.id_hospede = reservas.id_hospede
WHERE reservas.status_reserva = 'No-show'
GROUP BY hospedes.id_hospede, hospedes.nome, hospedes.email
ORDER BY total_no_show DESC
LIMIT 20;

