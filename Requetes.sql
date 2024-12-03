Use Pharmacie

--afficher la liste des  medicaments qui se prenne  oralement
SELECT DISTINCT M.numero_medicament,M.nom_medicament
FROM Medicament as M
JOIN indication as I ON I.numero_medicament = m.numero_medicament 
GO


--la liste des effet secondaire qui donne les maux de tete
SELECT DISTINCT numero_medicament, effet_secondaire
FROM indication
WHERE effet_secondaire = 'Maux de tête';
GO


---la liste des medicament qui sont des narcotique

CREATE VIEW vue_narcotiques AS
SELECT nom_medicament
FROM Medicament as M inner join Indication as I on m.numero_medicament = I.numero_medicament
WHERE est_narcotique = 1
GO


--La liste des clients qui ont qui ont une allergie et dont le nom commence par la lettre B
SELECT Client.nom ,numero_client
FROM client
WHERE nom LIKE 'B%' AND allergie IS NOT NULL;
GO


---le nombre de client age de -12 ans 
SELECT COUNT(*) AS nombreclient
FROM Client
where age < 12
GO


---gerant---
---catgorie de  medicaments les plus demandées par les clients
SELECT COUNT(categorie) AS nombre_demandes
FROM Medicament 
GROUP BY .categorie
ORDER BY nombre_demandes DESC
GO

--liste medicaments qui sont disponible dans la pharmacie
SELECT DISTINCT M.nom_medicament,disponibilite
FROM Medicament AS M
JOIN Distribution AS D ON M.numero_medicament = D.numero_medicament
WHERE D.disponibilite = 1;
GO

---la moyenne des prix des medicaments qui sont des antibiotiques  
SELECT AVG(prix) AS prix_moyen
FROM Distribution AS D
JOIN Medicament AS M ON D.numero_medicament = M.numero_medicament
WHERE M.categorie = 'Antibiotique'
GROUP BY categorie
GO

--le nom des fournisseur bases au japon--
SELECT numero_fournisseur, nom, pays
FROM Fournisseur
WHERE pays = 'Japan';
GO

---prix des medicaments qui depasse 100$
SELECT M.nom_medicament, D.prix
FROM Medicament AS M
JOIN Distribution AS D ON M.numero_medicament = D.numero_medicament
WHERE prix > 100;
GO