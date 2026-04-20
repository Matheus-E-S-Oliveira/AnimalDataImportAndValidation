/****************************************************************************************
 Procedure: dbo.sp_Animais_Divergencias

 Descrição:
    Responsável por identificar divergências entre os dados de animais já
    existentes na base (dbo.Animal_TEST) e os dados importados na tabela de staging
    (dbo.Animal_Importacao).

 Objetivo:
    - Comparar registros entre base e importação
    - Detectar inconsistências de dados
    - Retornar apenas os registros com divergência

 Regras de Comparação:
    - A correspondência entre registros é feita por:
        • RGD (quando disponível) OU
        • RGN
      E também pelo nome do animal

    - Os campos analisados para divergência são:
        • dataNascimento
        • sexo

    - Valores NULL são tratados como:
        • dataNascimento -> '1900-01-01'
        • sexo -> ''

 Fluxo de Execução:
    1. Realiza o JOIN entre Animal_TEST e Animal_Importacao
    2. Compara os campos definidos
    3. Identifica divergências campo a campo
    4. Retorna apenas registros com diferenças

 Retorno:
    - Identificador do animal (RGD ou RGN)
    - Nome do animal
    - Valores do banco
    - Valores da importação
    - Flags de divergência por campo
    - Lista textual dos campos divergentes

 Dependências:
    - dbo.Animal_TEST
    - dbo.Animal_Importacao

 Observações:
    - A procedure não altera dados
    - Serve apenas para análise e validação
    - Pode ser utilizada para auditoria ou revisão manual

 Autor: [Matheus Eric Santos de Oliveira]
 Data: [20/04/2026]
****************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.sp_Animais_Divergencias
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------------------
    -- Seleção de registros com divergência
    ------------------------------------------------------------------------
    SELECT 
        -- Identificador único (prioridade para RGD)
        COALESCE(A.RGD, A.RGN) AS Identificador,

        -- Nome do animal
        A.nome,

        -- Dados atuais no banco
        A.dataNascimento AS DataNascimento_Banco,
        A.sexo AS Sexo_Banco,

        -- Dados vindos da importação
        AI.dataNascimento AS DataNascimento_Importacao,
        AI.sexo AS Sexo_Importacao,

        --------------------------------------------------------------------
        -- Flags de divergência
        --------------------------------------------------------------------
        CASE 
            WHEN ISNULL(A.dataNascimento, '1900-01-01') 
               <> ISNULL(AI.dataNascimento, '1900-01-01')
            THEN 1 ELSE 0 
        END AS Divergencia_DataNascimento,

        CASE 
            WHEN ISNULL(A.sexo, '') <> ISNULL(AI.sexo, '')
            THEN 1 ELSE 0 
        END AS Divergencia_Sexo,

        --------------------------------------------------------------------
        -- Lista textual de campos divergentes
        --------------------------------------------------------------------
        CONCAT(
            CASE 
                WHEN ISNULL(A.dataNascimento, '1900-01-01') 
                   <> ISNULL(AI.dataNascimento, '1900-01-01')
                THEN 'DataNascimento; ' ELSE '' 
            END,
            CASE 
                WHEN ISNULL(A.sexo, '') <> ISNULL(AI.sexo, '')
                THEN 'Sexo; ' ELSE '' 
            END
        ) AS CamposDivergentes

    FROM dbo.Animal_TEST A

    INNER JOIN dbo.Animal_Importacao AI
        ON (
            (A.RGD IS NOT NULL AND A.RGD = AI.RGD)
            OR
            (A.RGN IS NOT NULL AND A.RGN = AI.RGN)
        )
        AND A.nome = AI.nome

    ------------------------------------------------------------------------
    -- Filtro: apenas registros com divergência
    ------------------------------------------------------------------------
    WHERE
        (
            ISNULL(A.dataNascimento, '1900-01-01') 
                <> ISNULL(AI.dataNascimento, '1900-01-01')
            OR
            ISNULL(A.sexo, '') <> ISNULL(AI.sexo, '')
        )
END;