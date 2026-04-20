/****************************************************************************************
 Script: create_table_animal_test.sql

 TABELA DE TESTE - NÃO UTILIZAR EM PRODUÇÃO

 Descrição:
    Script responsável pela criação da tabela dbo.Animal_TEST para fins
    exclusivamente de testes durante o desenvolvimento da rotina de
    importação de animais.

 Objetivo:
    - Simular a tabela final de animais
    - Validar inserções oriundas da tabela de staging (Animal_Importacao)
    - Testar regras de duplicidade e integridade

 Importante:
    - Esta tabela NÃO representa a estrutura final do sistema
    - Pode ser alterada ou removida a qualquer momento
    - NÃO deve ser utilizada em ambiente produtivo

 Estrutura:
    - RGN / RGD: Identificadores do animal
    - nome: Nome do animal
    - sexo: Sexo (M/F)
    - dataNascimento: Data de nascimento
    - paiId / maeId: Referência genealógica

 Regras:
    - Pelo menos um identificador deve existir (RGD ou RGN)

 Observações:
    - A estrutura oficial deverá ser definida posteriormente
    - Este script pode ser removido sem impacto no sistema final

****************************************************************************************/

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables 
    WHERE name = 'Animal_TEST'
      AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.Animal_TEST( 
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

    CREATE NONCLUSTERED INDEX IX_Animal_TEST_RGD_RGN_Nome
    ON dbo.Animal_TEST (RGD, RGN, nome);

    ALTER TABLE dbo.Animal_TEST
    ADD CONSTRAINT CK_Animal_TEST_Identificador
    CHECK (RGD IS NOT NULL OR RGN IS NOT NULL);
END;