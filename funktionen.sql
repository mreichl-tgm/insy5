-- AUTHOR: Markus Reichl
-- VERSION: 06.10.2017

-- Übung: Funktion mit 2 Parametern
-- Erstelle eine Funktion mit zwei Parametern: Alle Speisen die billiger als der Durchschnittspreis aller Speisen sind, sollen um einen fixen Betrag erhöht werden, alle Speisen die teurer sind, sollen um einen Prozentwert erhöht werden. 
CREATE OR REPLACE FUNCTION preisavg() RETURNS NUMERIC AS $$ SELECT avg(preis) FROM speise; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION preiserhoehung(INTEGER, INTEGER) RETURNS VOID AS $$
    UPDATE speise SET preis = preis + $1 WHERE preis < preisavg();
    UPDATE speise SET preis = preis * (100 + $2) / 100 WHERE preis >= preisavg();
$$ LANGUAGE SQL;

-- Übung: Tagesumsatz
-- Der Tagesumsatz für einen bestimmten Kellner soll für den aktuellen Tag ermittelt werden (Kellner-Nr via Parameter, aktueller Tag via CURRENT_DATE).
CREATE OR REPLACE FUNCTION preiserhoehung(INTEGER, INTEGER) RETURNS NUMERIC AS $$
    SELECT * FROM rechnung WHERE status = 'bezahlt' JOIN kellner;
$$ LANGUAGE SQL;

-- RÜCKGABEWERTE
-- Möglichkeiten:
-- 1) SELECT    SUM(), AVG(), MAX(), MIN(), COUNT()
-- 2) SELECT    17 + 4;
-- 3) SELECT    spalte LIMIT 1;


-- AUTHOR: Markus Reichl
-- VERSION: 03.11.2017

-- Kellner Umsatz
CREATE OR REPLACE FUNCTION kellnerumsatz(INTEGER) RETURNS NUMERIC AS $$
	SELECT SUM(speise.preis*bestellung.anzahl)
	FROM speise, rechnung, bestellung
	WHERE speise.snr=bestellung.snr
	AND rechnung.rnr=bestellung.rnr
	AND rechnung.knr=$1
	AND rechnung.status='bezahlt';
$$ LANGUAGE SQL;

-- AUTHOR: Markus Reichl
-- VERSION: 10.11.2017

-- Kellner Umsatz
CREATE OR REPLACE FUNCTION kellnerumsatz(INTEGER) RETURNS NUMERIC AS $$
	SELECT SUM(speise.preis*bestellung.anzahl)
	FROM speise, rechnung, bestellung
	WHERE speise.snr=bestellung.snr
	AND rechnung.rnr=bestellung.rnr
	AND rechnung.knr=$1
	AND rechnung.status='bezahlt';
$$ LANGUAGE SQL;

SELECT * FROM kellnerumsatz(1);

-- AUTHOR: Markus Reichl
-- VERSION: 10.11.2017

-- Mwst
CREATE OR REPLACE FUNCTION preisBrutto(speise) RETURNS DECIMAL(4,2) AS $$
	SELECT $1.preis * 1.2;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION preisMwst(speise) RETURNS DECIMAL(4,2) AS $$
	SELECT $1.preis * 0.2;
$$ LANGUAGE SQL;

SELECT bezeichnung, preisBrutto(speise.*) as "Brutto", preisMwst(speise.*) as "Mwst." FROM speise;

-- AUTHOR: Markus Reichl
-- VERSION: 12.11.2017

-- Noch nie bestellte Speisen
CREATE TABLE speisepreis(
	bezeichnung VARCHAR(255), 
	nettopreis DECIMAL(5, 2)
);

CREATE OR REPLACE FUNCTION nieBestellteSpeisen() 
RETURNS SETOF speisepreis AS $$
	SELECT speise.bezeichnung AS "Bezeichnung", speise.preis AS "Nettopreis"
	FROM speise
	WHERE speise.snr NOT IN (SELECT snr FROM bestellung);
$$ LANGUAGE SQL;

SELECT * FROM nieBestellteSpeisen();

DROP FUNCTION nieBestellteSpeisen;
DROP TABLE speisepreis;