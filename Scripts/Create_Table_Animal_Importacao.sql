IF NOT EXISTS (
    SELECT 1
    FROM sys.tables 
    WHERE name = 'Animal_Importacao'
      AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.Animal_Importacao (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        RGN VARCHAR(20) NULL,
        RGD VARCHAR(20) NULL,
        nome VARCHAR(100) NULL,
        sexo CHAR(1) NULL,
        identificador VARCHAR(20) NOT NULL,
        dataNascimento SMALLDATETIME NULL,
        DataImportacao DATETIME DEFAULT GETDATE(),
        paiId VARCHAR(10),
        maeId VARCHAR(10)
    );

    CREATE NONCLUSTERED INDEX IX_Animal_Importacao_RGD_RGN_Nome
    ON dbo.Animal_Importacao (RGD, RGN, nome);

    ALTER TABLE dbo.Animal_Importacao
    ADD CONSTRAINT CK_Animal_Identificador
    CHECK (RGD IS NOT NULL OR RGN IS NOT NULL);
END;