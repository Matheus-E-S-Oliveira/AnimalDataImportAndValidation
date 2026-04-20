/****************************************************************************************
 Script: insert_animais_teste.sql

  SCRIPT DE TESTE - NÃO UTILIZAR EM PRODUÇÃO 

 Descrição:
    Script utilizado para testes manuais de inserção de dados na tabela dbo.Animal_TEST,
    a partir da tabela de staging dbo.Animal_Importacao.

 Objetivo:
    - Validar comportamento de inserção
    - Testar regra de não duplicidade
    - Auxiliar durante desenvolvimento

 Observações:
    - Não faz parte do fluxo oficial
    - Não é utilizado por nenhuma procedure ou aplicação
    - A lógica oficial está na procedure:
        dbo.sp_Processar_Importacao_Animais

****************************************************************************************/

INSERT INTO dbo.Animal_TEST(
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

LEFT JOIN dbo.Animal A
    ON (
        (A.RGD IS NOT NULL AND A.RGD = AI.RGD)
        OR
        (A.RGN IS NOT NULL AND A.RGN = AI.RGN)
    )
    AND A.nome = AI.nome

WHERE A.Id IS NULL;