/* Alunos: Fernando Cardoso, João Pedro e Kayo Kawam
Matéria: Programação em Banco de Dados
Atividade: P2


Descrição do Banco de Dados

19- Reading frequency (scientific books/journals): (1: None, 2: Sometimes, 3: Often)

22- Attendance to classes (1: always, 2: sometimes, 3: never)

32- Grade (0: Fail, 1: DD, 2: DC, 3: CC, 4: CB, 5: BB, 6: BA, 7: AA)

*/



-- Exercícios
/* 1.3 Crie uma tabela apropriada para o armazenamento dos itens. Não se preocupe com a
normalização. Uma tabela basta. */

CREATE TABLE tb_alunos(
	studentid SERIAL PRIMARY KEY,
	read_freq_sci INT,
	attend INT,
	grade INT

);

-- Analisando se o dados foram importados corretamente
SELECT * FROM tb_alunos;


/*
-- 1.5 Escreva um stored procedure que responde (devolve um valor booleano) se é verdade
que todos os alunos que lêem artigos científicos (atributo 19) com frequência (often) e
sempre (always) assistem às aulas (atributo 22) são aprovados.
*/

CREATE OR REPLACE FUNCTION f_aluno_artigo_aula()
RETURNS BOOLEAN AS $$

DECLARE
	
	n_alunos_artigo INT;
	n_alunos_aula INT;
	p_alunos_total FLOAT;

BEGIN
	
	SELECT COUNT(*) INTO n_alunos_artigo
    FROM tb_alunos
    WHERE read_freq_sci = 3;
	
	SELECT COUNT(*) INTO n_alunos_aula
    FROM tb_alunos
    WHERE attend = 1;
	
	p_alunos_total := n_alunos_artigo * 100 / n_alunos_aula;
	
	IF p_alunos_total = 100.0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
	
END;
$$ LANGUAGE plpgsql


-- Criando Bloco Anônimo
DO
$$
DECLARE

resultado BOOLEAN;

BEGIN
	
	resultado := f_aluno_artigo_aula();
	RAISE NOTICE 'É verdade que todos os alunos que lêem artigos científicos com frequência e sempre assistem às aulas são aprovados: %', resultado;

END;
$$


/*
1.6.1 - percorra os dados de cima para baixo, removendo da tabela todos 
os alunos não aprovados
*/

-- Observando quais alunos não foram aprovados
SELECT * FROM tb_alunos
WHERE grade = 0;

-- Criando o Cursor
DO $$
DECLARE

	cur_delete REFCURSOR;
	tupla RECORD;
	
BEGIN

	OPEN cur_delete SCROLL FOR
		SELECT * FROM tb_alunos;
	
	LOOP
		FETCH cur_delete INTO tupla;
		EXIT WHEN NOT FOUND;
		IF tupla.grade = 0 THEN
			DELETE FROM tb_alunos
			WHERE CURRENT OF cur_delete;
		END IF;
	END LOOP;
	LOOP
		FETCH BACKWARD FROM cur_delete INTO tupla;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE '%', tupla;
	END LOOP;
	CLOSE cur_delete;

END;
$$


/*
-- 1.6.2 - percorra os dados de baixo para cima mostrando os nomes e conceitos 
dos alunos restantes
*/

DO $$
DECLARE
	cur_alunos_reverse CURSOR FOR
		SELECT studentid, grade FROM tb_alunos
		ORDER BY studentid DESC;
	tupla RECORD;
	resultado TEXT DEFAULT '';
BEGIN
	OPEN cur_alunos_reverse;
	FETCH LAST FROM cur_alunos_reverse INTO tupla;

	WHILE FOUND LOOP
		resultado := resultado || tupla.studentid || ', ' || tupla.grade || E'\n';
		FETCH PRIOR FROM cur_alunos_reverse INTO tupla;
		IF NOT FOUND THEN
			EXIT;
		END IF;
	END LOOP;

	CLOSE cur_alunos_reverse;
	RAISE NOTICE '%', resultado;
END;
$$

