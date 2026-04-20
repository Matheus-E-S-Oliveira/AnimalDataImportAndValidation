INSERT INTO dbo.Animal(
	RGN, RGD, nome, sexo, dataNascimento, paiId, maeId
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