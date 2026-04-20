CREATE OR ALTER PROCEDURE dbo.sp_Animais_Divergencias
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        COALESCE(A.RGD, A.RGN) AS Identificador,
        A.nome,

        A.dataNascimento AS DataNascimento_Banco,
        A.sexo AS Sexo_Banco,

        AI.dataNascimento AS DataNascimento_Importacao,
        AI.sexo AS Sexo_Importacao,

        CASE 
            WHEN ISNULL(A.dataNascimento, '1900-01-01') 
               <> ISNULL(AI.dataNascimento, '1900-01-01')
            THEN 1 ELSE 0 
        END AS Divergencia_DataNascimento,

        CASE 
            WHEN ISNULL(A.sexo, '') <> ISNULL(AI.sexo, '')
            THEN 1 ELSE 0 
        END AS Divergencia_Sexo,


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

    FROM dbo.Animal A

    INNER JOIN dbo.Animal_Importacao AI
        ON (
            (A.RGD IS NOT NULL AND A.RGD = AI.RGD)
            OR
            (A.RGN IS NOT NULL AND A.RGN = AI.RGN)
        )
        AND A.nome = AI.nome

    WHERE
        (
            ISNULL(A.dataNascimento, '1900-01-01') 
                <> ISNULL(AI.dataNascimento, '1900-01-01')
            OR
            ISNULL(A.sexo, '') <> ISNULL(AI.sexo, '')
        )
END;