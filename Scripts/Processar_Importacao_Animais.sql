CREATE OR ALTER PROCEDURE dbo.sp_Processar_Importacao_Animais
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Animal (
        RGN,
        RGD,
        nome,
        sexo,
        dataNascimento,
        paiId,
        maeId
    )
    SELECT 
        AI.RGN,
        AI.RGD,
        AI.nome,
        AI.sexo,
        AI.dataNascimento,
        AI.paiId,
        AI.maeId
    FROM dbo.Animal_Importacao AI
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Animal A
        WHERE 
            (
                (A.RGD IS NOT NULL AND A.RGD = AI.RGD)
                OR
                (A.RGN IS NOT NULL AND A.RGN = AI.RGN)
            )
            AND A.nome = AI.nome
    );

    EXEC dbo.sp_Animais_Divergencias;

END;