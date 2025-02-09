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
-- Table structure for table `subfuncao`
--

DROP TABLE IF EXISTS `subfuncao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subfuncao` (
  `codigo_subfuncao` varchar(50) NOT NULL,
  `nome_subfuncao` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`codigo_subfuncao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subfuncao`
--

LOCK TABLES `subfuncao` WRITE;
/*!40000 ALTER TABLE `subfuncao` DISABLE KEYS */;
INSERT INTO `subfuncao` VALUES ('092','Representação judicial e extrajudicial'),('121','Planejamento e orçamento'),('122','Administração geral'),('124','Controle interno'),('125','Normatização e fiscalização'),('126','Tecnologia da informação'),('127','Ordenamento territorial'),('128','Formação de recursos humanos'),('131','Comunicação social'),('151','Defesa aérea'),('152','Defesa naval'),('153','Defesa terrestre'),('181','Policiamento'),('182','Defesa civil'),('183','Informação e inteligência'),('211','Relações diplomáticas'),('212','Cooperação internacional'),('241','Assistência ao idoso'),('242','Assistência ao portador de deficiência'),('243','Assistência à criança e ao adolescente'),('244','Assistência comunitária'),('271','Previdência básica'),('301','Atenção básica'),('302','Assistência hospitalar e ambulatorial'),('303','Suporte profilático e terapêutico'),('304','Vigilância sanitária'),('305','Vigilância epidemiológica'),('306','Alimentação e nutrição'),('333','Empregabilidade'),('334','Fomento ao trabalho'),('363','Ensino profissional'),('364','Ensino superior'),('365','Educação infantil'),('366','Educação de jovens e adultos'),('367','Educação especial'),('368','Educação básica'),('391','Patrimônio histórico, artístico e arqueológico'),('392','Difusão cultural'),('421','Custódia e reintegração social'),('422','Direitos individuais, coletivos e difusos'),('423','Assistência aos povos indígenas'),('451','infra-estrutura urbana'),('452','Serviços urbanos'),('453','Transportes coletivos urbanos'),('482','Habitação urbana'),('511','Saneamento básico rural'),('512','Saneamento básico urbano'),('541','Preservação e conservação ambiental'),('542','Controle ambiental'),('543','Recuperação de áreas degradadas'),('544','Recursos hídricos'),('545','Meteorologia'),('571','Desenvolvimento científico'),('572','Desenvolvimento tecnológico e engenharia'),('573','Difusão do conhecimento científico e tecnológico'),('605','Abastecimento'),('606','Extensão rural'),('607','Irrigação'),('608','Promoção da produção agropecuária'),('609','Defesa agropecuária'),('631','Reforma agrária'),('661','Promoção industrial'),('662','Produção industrial'),('663','Mineração'),('664','Propriedade industrial'),('665','Normalização e qualidade'),('691','Promoção comercial'),('693','Comércio exterior'),('695','Turismo'),('722','Telecomunicações'),('751','Conservação de energia'),('752','Energia elétrica'),('754','Biocombustíveis'),('781','Transporte aéreo'),('782','Transporte rodoviário'),('783','Transporte ferroviário'),('784','Transporte hidroviário'),('811','Desporto de rendimento'),('812','Desporto comunitário'),('813','Lazer'),('845','Outras transferências'),('846','Outros encargos especiais'),('847','Transferências para a educação básica'),('MU','Múltiplo');
/*!40000 ALTER TABLE `subfuncao` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-02-08 20:56:35
