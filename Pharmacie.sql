CREATE DATABASE Pharmacie
GO

USE Pharmacie
GO

CREATE TABLE Client
(
	numero_client INT IDENTITY NOT NULL,
	nom VARCHAR(20) NOT NULL,
	prenom VARCHAR(20) NOT NULL,
	allergie BIT NOT NULL,
	age INT CHECK (age >= 0) NOT NULL, -- L'âge doit etre superieur à 0
	CONSTRAINT pk_numero_client PRIMARY KEY CLUSTERED(numero_client),
)
GO



CREATE TABLE Fournisseur
(
	numero_fournisseur INT IDENTITY NOT NULL,
	nom VARCHAR(50) NOT NULL,
	pays VARCHAR(20) NOT NULL,
	CONSTRAINT pk_numero_fournisseur PRIMARY KEY CLUSTERED(numero_fournisseur),
)
GO

CREATE TABLE Medicament
(
	numero_medicament INT IDENTITY (1,1) NOT NULL,
	nom_medicament VARCHAR(250) NOT NULL,
	categorie VARCHAR(20) NOT NULL,
	date_expiration DATE NOT NULL,
	CONSTRAINT pk_numero_medicament PRIMARY KEY CLUSTERED (numero_medicament),
)
GO

CREATE TABLE Indication
(
    numero_medicament INT NOT NULL, -- Clé étrangère vers Medicament
    mode_administration VARCHAR(50) NOT NULL, 
    effet_secondaire VARCHAR(50) NOT NULL,
    est_narcotique BIT NOT NULL,
    deconseille_aux_enfants BIT NOT NULL,
    CONSTRAINT fk_numero_medicament FOREIGN KEY (numero_medicament) REFERENCES Medicament (numero_medicament),
)
GO

CREATE TABLE Distribution
(
    numero_medicament INT NOT NULL,
    numero_fournisseur INT NOT NULL,
    disponibilite BIT NOT NULL,
    prix INT NOT NULL,
    popularite VARCHAR(20) NOT NULL,
    CONSTRAINT pk_distribution PRIMARY KEY CLUSTERED (numero_medicament, numero_fournisseur),
    CONSTRAINT fk_distribution_medicament FOREIGN KEY (numero_medicament) REFERENCES Medicament (numero_medicament),
    CONSTRAINT fk_distribution_fournisseur FOREIGN KEY (numero_fournisseur) REFERENCES Fournisseur (numero_fournisseur)
)
GO


CREATE TABLE Consommation
(
    numero_client INT NOT NULL,
    numero_medicament INT NOT NULL,
    CONSTRAINT pk_consommation PRIMARY KEY CLUSTERED (numero_client, numero_medicament),
    CONSTRAINT fk_consommation_client FOREIGN KEY (numero_client) 
        REFERENCES Client(numero_client),
    CONSTRAINT fk_consommation_medicament FOREIGN KEY (numero_medicament) 
        REFERENCES Medicament(numero_medicament)
)
GO

SELECT * FROM Client
SELECT * FROM Fournisseur
SELECT * FROM Medicament
SELECT * FROM Indication
SELECT * FROM Distribution
SELECT * FROM Consommation