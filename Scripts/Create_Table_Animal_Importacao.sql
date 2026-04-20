/****************************************************************************************
 Script: 001_create_table_animal_importacao.sql

 Descrição:
    Cria a tabela de staging dbo.Animal_Importacao, utilizada para armazenar
    temporariamente os dados de animais provenientes de arquivos externos
    (JSON, etc.) antes do processamento e inserção na tabela final.

 Objetivo:
    - Servir como área intermediária (staging)
    - Permitir validação e tratamento dos dados antes da persistência definitiva
    - Isolar o processo de importação do modelo principal

 Comportamento:
    - Verifica se a tabela já existe no schema dbo
    - Caso não exista, realiza a criação da tabela, índice e constraint
    - Caso exista, o script não executa nenhuma ação (idempotente)

 Estrutura da Tabela:
    - Id: Identificador único do registro (IDENTITY)
    - RGN: Registro Genealógico Nacional
    - RGD: Registro Genealógico Definitivo
    - nome: Nome do animal
    - sexo: Sexo do animal (ex: M/F)
    - identificador: Identificador calculado (RGD ou RGN) utilizado no processo
    - dataNascimento: Data de nascimento do animal
    - DataImportacao: Data/hora em que o registro foi inserido na staging
    - paiId: Identificador do pai
    - maeId: Identificador da mãe

 Índices:
    - IX_Animal_Importacao_RGD_RGN_Nome:
        Otimiza buscas durante validação e comparação com a tabela final

 Constraints:
    - CK_Animal_Identificador:
        Garante que pelo menos um dos campos (RGD ou RGN) esteja preenchido

 Dependências:
    - Utilizada pelas procedures:
        • dbo.sp_Processar_Importacao_Animais
        • dbo.sp_Animais_Divergencias

 Observações:
    - A tabela pode ser truncada antes de cada nova importação
    - Não deve ser utilizada como fonte definitiva de dados
    - O campo "identificador" é auxiliar e não representa chave oficial

 Autor: [Matheus Eric Santos de Oliveira]
 Data: [20/04/2026]
****************************************************************************************/

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables 
    WHERE name = 'Animal_Importacao'
      AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.Animal_Importacao (
        
        -- Identificador único do registro
        Id INT IDENTITY(1,1) PRIMARY KEY,

        -- Registro Genealógico Nacional
        RGN VARCHAR(20) NULL,

        -- Registro Genealógico Definitivo
        RGD VARCHAR(20) NULL,

        -- Nome do animal
        nome VARCHAR(100) NULL,

        -- Sexo do animal (M/F)
        sexo CHAR(1) NULL,

        -- Identificador auxiliar (RGD ou RGN)
        identificador VARCHAR(20) NOT NULL,

        -- Data de nascimento
        dataNascimento SMALLDATETIME NULL,

        -- Data/hora da importação
        DataImportacao DATETIME DEFAULT GETDATE(),

        -- Identificador do pai
        paiId VARCHAR(10),

        -- Identificador da mãe
        maeId VARCHAR(10)
    );

    ------------------------------------------------------------------------
    -- Índice para otimização de consultas
    ------------------------------------------------------------------------
    CREATE NONCLUSTERED INDEX IX_Animal_Importacao_RGD_RGN_Nome
    ON dbo.Animal_Importacao (RGD, RGN, nome);

    ------------------------------------------------------------------------
    -- Constraint para garantir integridade dos dados
    ------------------------------------------------------------------------
    ALTER TABLE dbo.Animal_Importacao
    ADD CONSTRAINT CK_Animal_Identificador
    CHECK (RGD IS NOT NULL OR RGN IS NOT NULL);
END;