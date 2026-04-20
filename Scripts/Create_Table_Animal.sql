IF NOT EXISTS (
    SELECT 1
    FROM sys.tables 
    WHERE name = 'Animal'
      AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.Animal( 
        Id INT IDENTITY(1,1) PRIMARY KEY,
        RGN VARCHAR(20) NULL,
        RGD VARCHAR(20) NULL,
        nome VARCHAR(100) NULL,
        sexo CHAR(1) NULL,
        dataNascimento DATETIME2 NULL,
        DataImportacao DATETIME DEFAULT GETDATE(),
        paiId VARCHAR(20),
        maeId VARCHAR(20)
    );

    CREATE NONCLUSTERED INDEX IX_Animal_RGD_RGN_Nome
    ON dbo.Animal (RGD, RGN, nome);

    ALTER TABLE dbo.Animal
    ADD CONSTRAINT CK_Animal_Identificador
    CHECK (RGD IS NOT NULL OR RGN IS NOT NULL);
END;