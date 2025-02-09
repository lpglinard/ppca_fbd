CREATE DATABASE  IF NOT EXISTS `emendas_parlamentares` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `emendas_parlamentares`;
-- MySQL dump 10.13  Distrib 8.0.40, for macos14 (arm64)
--
-- Host: 127.0.0.1    Database: emendas_parlamentares
-- ------------------------------------------------------
-- Server version	8.4.4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `vw_localidade_emenda`
--

DROP TABLE IF EXISTS `vw_localidade_emenda`;
/*!50001 DROP VIEW IF EXISTS `vw_localidade_emenda`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_localidade_emenda` AS SELECT 
 1 AS `id_emenda`,
 1 AS `localidade`,
 1 AS `ano_da_emenda`,
 1 AS `nome_funcao`,
 1 AS `nome_subfuncao`,
 1 AS `valor_empenhado`,
 1 AS `valor_pago`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_localidade_emenda`
--

/*!50001 DROP VIEW IF EXISTS `vw_localidade_emenda`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_localidade_emenda` AS select `eo`.`id_emenda` AS `id_emenda`,(case when (`eo`.`id_cidade` is not null) then concat(`c`.`nome_cidade`,' - ',coalesce(`est`.`sigla_uf`,'UF Desconhecida')) when (`eo`.`id_estado` is not null) then `est`.`nome_estado` when (`eo`.`id_regiao` is not null) then `r`.`nome_regiao` when (`eo`.`id_abrangencia` is not null) then `ae`.`nome_abrangencia` else 'Localidade indefinida' end) AS `localidade`,`eo`.`ano_da_emenda` AS `ano_da_emenda`,`f`.`nome_funcao` AS `nome_funcao`,`s`.`nome_subfuncao` AS `nome_subfuncao`,coalesce(`eo`.`valor_empenhado`,0.00) AS `valor_empenhado`,coalesce(`eo`.`valor_pago`,0.00) AS `valor_pago` from ((((((`emendas_otimizada` `eo` left join `cidade` `c` on((`eo`.`id_cidade` = `c`.`id_cidade`))) left join `estado` `est` on((`c`.`id_estado` = `est`.`id_estado`))) left join `regiao` `r` on((`eo`.`id_regiao` = `r`.`id_regiao`))) left join `abrangencia_especial` `ae` on((`eo`.`id_abrangencia` = `ae`.`id_abrangencia`))) left join `funcao` `f` on((`eo`.`id_funcao` = `f`.`codigo_funcao`))) left join `subfuncao` `s` on((`eo`.`id_subfuncao` = `s`.`codigo_subfuncao`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Dumping events for database 'emendas_parlamentares'
--

--
-- Dumping routines for database 'emendas_parlamentares'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_analisar_emendas_transparencia` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_analisar_emendas_transparencia`(IN p_ano_da_emenda int, IN p_id_autor int)
BEGIN
    -- Declaração de variáveis
    DECLARE v_id_emenda INT;
    DECLARE v_ano_da_emenda INT;
    DECLARE v_nome_autor VARCHAR(255);
    DECLARE v_localidade VARCHAR(255);
    DECLARE v_valor_empenhado DECIMAL(15, 2);
    DECLARE v_valor_liquidado DECIMAL(15, 2);
    DECLARE v_valor_pago DECIMAL(15, 2);
    DECLARE v_restos_a_pagar DECIMAL(15, 2);
    DECLARE v_nivel_risco ENUM('BAIXO', 'MEDIO', 'ALTO');
    DECLARE v_mensagem TEXT;
    DECLARE done INT DEFAULT 0;

    -- Cursor para iterar as emendas
    DECLARE cur_emendas CURSOR FOR
        SELECT eo.id_emenda, eo.ano_da_emenda, a.nome_do_autor_da_emenda,
               CASE
                   WHEN eo.id_cidade IS NOT NULL THEN CONCAT(c.nome_cidade, ' - ', est.sigla_uf)
                   WHEN eo.id_estado IS NOT NULL THEN est.nome_estado
                   WHEN eo.id_regiao IS NOT NULL THEN r.nome_regiao
                   WHEN eo.id_abrangencia IS NOT NULL THEN ae.nome_abrangencia
                   ELSE 'Localidade indefinida'
               END AS localidade,
               eo.valor_empenhado, eo.valor_liquidado, eo.valor_pago, eo.valor_restos_a_pagar_inscritos
        FROM emendas_otimizada eo
        LEFT JOIN autor a ON eo.id_autor = a.codigo_do_autor_da_emenda
        LEFT JOIN cidade c ON eo.id_cidade = c.id_cidade
        LEFT JOIN estado est ON c.id_estado = est.id_estado
        LEFT JOIN regiao r ON eo.id_regiao = r.id_regiao
        LEFT JOIN abrangencia_especial ae ON eo.id_abrangencia = ae.id_abrangencia
        WHERE eo.ano_da_emenda = p_ano_da_emenda AND eo.id_autor = p_id_autor;

    -- Controlador de término do loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Primeiro, apagar os registros anteriores do log
    DELETE FROM log_relatorio_emendas;

    -- Abrir o cursor
    OPEN cur_emendas;

    read_loop: LOOP
        -- Ler os dados do cursor
        FETCH cur_emendas INTO v_id_emenda, v_ano_da_emenda, v_nome_autor, v_localidade,
                             v_valor_empenhado, v_valor_liquidado, v_valor_pago, v_restos_a_pagar;

        -- Verificar se o loop deve terminar
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Classificação do nível de risco com base na lógica ajustada
        IF v_valor_pago > v_valor_liquidado THEN
            SET v_nivel_risco = 'ALTO';
            SET v_mensagem = CONCAT('Valor pago (', v_valor_pago, ') superior ao valor liquidado (', v_valor_liquidado, '). Verificar possível irregularidade.');
        ELSEIF v_restos_a_pagar > (v_valor_empenhado * 0.5) THEN
            SET v_nivel_risco = 'MEDIO';
            SET v_mensagem = CONCAT('Restos a pagar elevados: ', v_restos_a_pagar, ' (> 50% do valor empenhado).');
        ELSE
            SET v_nivel_risco = 'BAIXO';
            SET v_mensagem = 'Emenda dentro dos parâmetros normais.';
        END IF;

        -- Inserir o registro no log
        INSERT INTO log_relatorio_emendas (
            id_emenda, ano_da_emenda, autor_emenda, localidade, nivel_risco, mensagem
        )
        VALUES (
            v_id_emenda, v_ano_da_emenda, v_nome_autor, v_localidade, v_nivel_risco, v_mensagem
        );
    END LOOP;

    -- Fechar o cursor
    CLOSE cur_emendas;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-02-08 20:56:36
