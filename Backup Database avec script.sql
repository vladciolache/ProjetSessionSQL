BACKUP DATABASE Pharmacie
        TO  DISK = 'G:\A24\EXPLOITATION_DES_BASES DE_DONN�ES\Projet_de_session\MaBaseDonnees.bak'
        WITH  RETAINDAYS = 90
        , NAME = 'MaBaseDonnees - Sauvegarde compl�te'
        , COMPRESSION ;
GO