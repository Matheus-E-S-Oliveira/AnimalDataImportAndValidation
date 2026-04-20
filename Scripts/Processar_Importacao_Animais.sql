/****************************************************************************************
 Procedure: dbo.sp_Processar_Importacao_Animais

 Descrição:
    Responsável por processar os dados de animais importados na tabela de staging
    (dbo.Animal_Importacao), realizando a inserção controlada na tabela final
    (dbo.Animal_TEST) e executando a verificação de divergências.

 Objetivo:
    - Inserir novos animais na base de dados
    - Evitar duplicidade com base em RGD ou RGN + nome
    - Executar a procedure de divergências após o processamento

 Regras de Negócio:
    - Um animal é considerado existente se:
        • Possuir o mesmo RGD OU
        • Possuir o mesmo RGN
      E também possuir o mesmo nome
    - Caso o animal já exista, ele NÃO será inserido
    - Apenas novos registros serão adicionados à tabela dbo.Animal_TEST

 Fluxo de Execução:
    1. Leitura da tabela de staging (Animal_Importacao)
    2. Verificação de existência na tabela final (Animal_TEST)
    3. Inserção de novos registros
    4. Execução da procedure de divergências

 Dependências:
    - dbo.Animal_Importacao
    - dbo.Animal_TEST
    - dbo.sp_Animais_Divergencias

 Observações:
    - A procedure não realiza atualização de registros existentes
    - A identificação do animal depende de RGD ou RGN
    - O campo "nome" é utilizado como complemento na validação

 Autor: [Matheus Eric Santos de Oliveira]
 Data: [20/04/2026]
****************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.sp_Processar_Importacao_Animais
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------------------
    -- Inserção de novos animais
    ------------------------------------------------------------------------
    INSERT INTO dbo.Animal_TEST (
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
        FROM dbo.Animal_TEST A
        WHERE 
            (
                (A.RGD IS NOT NULL AND A.RGD = AI.RGD)
                OR
                (A.RGN IS NOT NULL AND A.RGN = AI.RGN)
            )
            AND A.nome = AI.nome
    );

    ------------------------------------------------------------------------
    -- Execução da verificação de divergências
    ------------------------------------------------------------------------
    EXEC dbo.sp_Animais_Divergencias;

END;