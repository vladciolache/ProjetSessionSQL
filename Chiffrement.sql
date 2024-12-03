use Pharmacie

-- Chiffrement

-- MASTER KEY
-- La créer
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Password01!';

-- L'ouvrir (au besoin)
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'Password01!'

-- En faire une sauvegarde
BACKUP MASTER KEY TO FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONNÉES\Projet_de_session\master_key'  
ENCRYPTION BY PASSWORD = 'Password01!'

-- Voir si la service master key (SMK) est définie
SELECT name, key_algorithm, key_length
FROM master.sys.symmetric_keys

-- En faire une sauvegarde
BACKUP SERVICE MASTER KEY TO FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONNÉES\Projet_de_session\sql2022_smk'  
ENCRYPTION BY PASSWORD = 'Password01!'


-- CRÉE UN CERTIFICAT
CREATE CERTIFICATE ClientCert 
WITH SUBJECT = 'Certificat pour chiffrement des noms clients',
EXPIRY_DATE = '20251231';

-- Faire une sauvegarde du certificat
BACKUP CERTIFICATE ClientCert TO FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONNÉES\Projet_de_session\ClientCert.pub' 
WITH PRIVATE KEY (
    FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONNÉES\Projet_de_session\ClientCert.priv', 
    ENCRYPTION BY PASSWORD = 'Password01!'
)

-- Restaurer le certificat
CREATE CERTIFICATE ClientCert FROM FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONNÉES\Projet_de_session\ClientCert.pub' 
WITH PRIVATE KEY (
    FILE = 'G:\A24\EXPLOITATION_DES_BASES DE_DONNÉES\Projet_de_session\ClientCert.priv', 
    ENCRYPTION BY PASSWORD = 'Password01!'
)

-- chiffrer/déchiffrer une colonne 'nom'
-- Modifier la table pour accepter les données chiffrées
ALTER TABLE Client
ALTER COLUMN nom VARBINARY(256);

-- Créer la clé asymétrique (KEK - Key Encryption Key)
CREATE ASYMMETRIC KEY ClientnomKEK WITH ALGORITHM = RSA_4096;

-- Créer la clé symétrique qui va chiffrer la colonne
CREATE SYMMETRIC KEY ClientnomKEK WITH ALGORITHM = AES_256 ENCRYPTION BY ASYMMETRIC KEY ClientnomKEK;

-- Ouvrir la clé symétrique
OPEN SYMMETRIC KEY ClientnomKEK
DECRYPTION BY ASYMMETRIC KEY ClientnomKEK;

-- Chiffrer les données existantes
UPDATE Client
SET nom = EncryptByKey(Key_GUID('ClientnomKEK'), nom, 1, CONVERT(varbinary, 'SaltPharma'));

-- Déchiffrer (s'assurer que la clé est ouverte)
SELECT numero_client,
    CONVERT(varchar(50), DecryptByKey(nom, 1, CONVERT(varbinary, 'SaltPharma'))) as nom_dechiffre,
    prenom,
    age
FROM Client;


-- Fermer la clé quand vous avez terminé
CLOSE SYMMETRIC KEY ClientnomKEK;


-- chiffrer/déchiffrer une colonne 'age'
-- Modifier la table pour accepter l'âge chiffré
ALTER TABLE Client
ALTER COLUMN age VARBINARY(256);

-- Créer une nouvelle clé asymétrique pour l'âge
CREATE ASYMMETRIC KEY ClientAgeKEK 
WITH ALGORITHM = RSA_4096;

-- Créer la clé symétrique pour chiffrer l'âge
CREATE SYMMETRIC KEY ClientAgeKey 
WITH ALGORITHM = AES_256
ENCRYPTION BY ASYMMETRIC KEY ClientAgeKEK;

-- Ouvrir la clé symétrique
OPEN SYMMETRIC KEY ClientAgeKey
DECRYPTION BY ASYMMETRIC KEY ClientAgeKEK;

-- Chiffrer les données d'âge existantes
UPDATE Client
SET age = EncryptByKey(Key_GUID('ClientAgeKey'), CONVERT(varchar(10), age), 1, CONVERT(varbinary, 'SaltAge'));

-- Déchiffrer (s'assurer que la clé est ouverte)
-- ajouter nom aussi pour pouvoir voir toutes les données en meme temps
SELECT numero_client,
    CONVERT(varchar(50), DecryptByKey(nom, 1, CONVERT(varbinary, 'SaltPharma'))) as nom_dechiffre,
    CONVERT(int, DecryptByKey(age, 1, CONVERT(varbinary, 'SaltAge'))) as age_dechiffre
FROM Client;

-- Fermer la clé
CLOSE SYMMETRIC KEY ClientAgeKey;