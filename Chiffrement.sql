use Pharmacie

-- Chiffrement

-- MASTER KEY
-- La cr�er
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Password01!';

-- L'ouvrir (au besoin)
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'Password01!'

-- En faire une sauvegarde
BACKUP MASTER KEY TO FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONN�ES\Projet_de_session\master_key'  
ENCRYPTION BY PASSWORD = 'Password01!'

-- Voir si la service master key (SMK) est d�finie
SELECT name, key_algorithm, key_length
FROM master.sys.symmetric_keys

-- En faire une sauvegarde
BACKUP SERVICE MASTER KEY TO FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONN�ES\Projet_de_session\sql2022_smk'  
ENCRYPTION BY PASSWORD = 'Password01!'


-- CR�E UN CERTIFICAT
CREATE CERTIFICATE ClientCert 
WITH SUBJECT = 'Certificat pour chiffrement des noms clients',
EXPIRY_DATE = '20251231';

-- Faire une sauvegarde du certificat
BACKUP CERTIFICATE ClientCert TO FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONN�ES\Projet_de_session\ClientCert.pub' 
WITH PRIVATE KEY (
    FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONN�ES\Projet_de_session\ClientCert.priv', 
    ENCRYPTION BY PASSWORD = 'Password01!'
)

-- Restaurer le certificat
CREATE CERTIFICATE ClientCert FROM FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONN�ES\Projet_de_session\ClientCert.pub' 
WITH PRIVATE KEY (
    FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONN�ES\Projet_de_session\ClientCert.priv', 
    ENCRYPTION BY PASSWORD = 'Password01!'
)

-- chiffrer/d�chiffrer une colonne 'nom'
-- Modifier la table pour accepter les donn�es chiffr�es
ALTER TABLE Client
ALTER COLUMN nom VARBINARY(256);

-- Cr�er la cl� asym�trique (KEK - Key Encryption Key)
CREATE ASYMMETRIC KEY ClientnomKEK WITH ALGORITHM = RSA_4096;

-- Cr�er la cl� sym�trique qui va chiffrer la colonne
CREATE SYMMETRIC KEY ClientnomKEK WITH ALGORITHM = AES_256 ENCRYPTION BY ASYMMETRIC KEY ClientnomKEK;

-- Ouvrir la cl� sym�trique
OPEN SYMMETRIC KEY ClientnomKEK
DECRYPTION BY ASYMMETRIC KEY ClientnomKEK;

-- Chiffrer les donn�es existantes
UPDATE Client
SET nom = EncryptByKey(Key_GUID('ClientnomKEK'), nom, 1, CONVERT(varbinary, 'SaltPharma'));

-- D�chiffrer (s'assurer que la cl� est ouverte)
SELECT numero_client,
    CONVERT(varchar(50), DecryptByKey(nom, 1, CONVERT(varbinary, 'SaltPharma'))) as nom_dechiffre,
    prenom,
    age
FROM Client;


-- Fermer la cl� quand vous avez termin�
CLOSE SYMMETRIC KEY ClientnomKEK;


-- chiffrer/d�chiffrer une colonne 'age'
-- Modifier la table pour accepter l'�ge chiffr�
ALTER TABLE Client
ALTER COLUMN age VARBINARY(256);

-- Cr�er une nouvelle cl� asym�trique pour l'�ge
CREATE ASYMMETRIC KEY ClientAgeKEK 
WITH ALGORITHM = RSA_4096;

-- Cr�er la cl� sym�trique pour chiffrer l'�ge
CREATE SYMMETRIC KEY ClientAgeKey 
WITH ALGORITHM = AES_256
ENCRYPTION BY ASYMMETRIC KEY ClientAgeKEK;

-- Ouvrir la cl� sym�trique
OPEN SYMMETRIC KEY ClientAgeKey
DECRYPTION BY ASYMMETRIC KEY ClientAgeKEK;

-- Chiffrer les donn�es d'�ge existantes
UPDATE Client
SET age = EncryptByKey(Key_GUID('ClientAgeKey'), CONVERT(varchar(10), age), 1, CONVERT(varbinary, 'SaltAge'));

-- D�chiffrer (s'assurer que la cl� est ouverte)
-- ajouter nom aussi pour pouvoir voir toutes les donn�es en meme temps
SELECT numero_client,
    CONVERT(varchar(50), DecryptByKey(nom, 1, CONVERT(varbinary, 'SaltPharma'))) as nom_dechiffre,
    CONVERT(int, DecryptByKey(age, 1, CONVERT(varbinary, 'SaltAge'))) as age_dechiffre
FROM Client;

-- Fermer la cl�
CLOSE SYMMETRIC KEY ClientAgeKey;