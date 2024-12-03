-- **Traitements automatisés**

--Maintenir l’intégrité référentielle dans la base de données lors de la suppression d’un
--enregistrement à l’aide des techniques appropriées (contraintes, déclencheurs). On devrait
--pouvoir supprimer un enregistrement de n’importe quelle table.


-- 1. Modifier les contraintes de clé étrangère pour ajouter ON DELETE CASCADE

ALTER TABLE Indication
DROP CONSTRAINT fk_numero_medicament
GO

ALTER TABLE Indication
ADD CONSTRAINT fk_numero_medicament 
FOREIGN KEY (numero_medicament) REFERENCES Medicament (numero_medicament)
GO

-- Déclencheur de suppression séquentielle des références d'un médicament

-- CASCADE supprime automatiquement tous les enregistrements correspondants 
-- dans les tables enfants (Indication et Distribution)

CREATE OR ALTER TRIGGER tr_delete_medicament
ON Medicament
INSTEAD OF DELETE
AS
BEGIN

    DELETE FROM Indication 
    WHERE numero_medicament IN (SELECT numero_medicament FROM deleted)
    
    DELETE FROM Distribution
    WHERE numero_medicament IN (SELECT numero_medicament FROM deleted)
    
    DELETE FROM Medicament 
    WHERE numero_medicament IN (SELECT numero_medicament FROM deleted)
END
GO

-- Test
DELETE FROM Medicament
WHERE numero_medicament = 1

----traitement automatises
---1---liste  les fournisseurs qui sont basés à l'extérieur du canada.(gerant)
GO
CREATE PROCEDURE sp_fournisseurs_exterieurs
    @pays_local VARCHAR(50)
AS
BEGIN
    SELECT *
    FROM Fournisseur
    WHERE pays != @pays_local;
END;
--appel de la fonction 
EXEC sp_fournisseurs_exterieurs @pays_local = 'canada';

--2--Déclencheur simple pour alerte sur les médicaments périmés
GO
CREATE OR ALTER TRIGGER tr_alerte_medicament_perime --(gerant/pharmacien)
ON Medicament
AFTER INSERT 
AS
BEGIN
    -- Vérifie si des médicaments sont périmés
    IF EXISTS (
        SELECT 1
        FROM Medicament
        WHERE date_expiration < GETDATE()
    )
    BEGIN
        --
        PRINT 'ALERTE : Certains médicaments dans la base de données sont périmés.';
    END;
END;
--test
INSERT INTO Medicament (nom_medicament, categorie, date_expiration)
VALUES ('Aspirine', 'Antidouleur', '2022-12-01'); -- Date passée


---3---medicament deconseiller au enfant-12ans (pharmacien)
GO
CREATE OR ALTER FUNCTION fn_DeconseilleAuxEnfants(@numero_medicament INT)
RETURNS BIT
AS
BEGIN
    DECLARE @deconseille BIT;
    SELECT @deconseille = deconseille_aux_enfants
    FROM Indication
    WHERE numero_medicament = @numero_medicament;

    RETURN @deconseille;
END;

--appele de la fonctions 
SELECT nom_medicament, dbo.fn_DeconseilleAuxEnfants(numero_medicament) AS est_deconseille
FROM Medicament;

--4--vérifier si un client est allergique à un médicament avant consommation(pharmacien)
CREATE OR ALTER PROCEDURE sp_VerifierAllergieMedicament
    @numero_client INT,
    @numero_medicament INT
AS
BEGIN
    DECLARE @allergie BIT;

    SELECT @allergie = allergie
    FROM Client
    WHERE numero_client = @numero_client;

    IF @allergie = 1
    BEGIN
        PRINT 'Attention : Ce client est allergique ! Vérifiez avant de consommer ce médicament.';
    END
    ELSE
    BEGIN
        PRINT 'Aucune allergie détectée.';
    END
END;
--test
EXEC sp_VerifierAllergieMedicament @numero_client = 1, @numero_medicament = 1;
--5--medicament en rupture de stock(gerant)
CREATE OR ALTER PROCEDURE sp_MedicamentsIndisponibles
AS
BEGIN
    SELECT M.nom_medicament, F.nom AS fournisseur
    FROM Medicament M
    JOIN Distribution D ON M.numero_medicament = D.numero_medicament
    JOIN Fournisseur F ON D.numero_fournisseur = F.numero_fournisseur
    WHERE D.disponibilite = 0;
END;

--appel
EXEC sp_MedicamentsIndisponibles;

-- 6 Fonction medicament narcotique
GO
CREATE OR ALTER FUNCTION fn_EstNarcotique(@numero_medicament INT)
RETURNS BIT
AS
BEGIN
    DECLARE @narcotique BIT;
    SELECT @narcotique = est_narcotique
    FROM Indication
    WHERE numero_medicament = @numero_medicament;
    RETURN @narcotique;
END;

SELECT dbo.fn_EstNarcotique(1)