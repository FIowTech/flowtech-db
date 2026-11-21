DROP DATABASE IF EXISTS flowtech;
CREATE DATABASE IF NOT EXISTS flowtech;
USE flowtech;

-- | CRIAÇÃO DAS TABELAS | --
CREATE TABLE IF NOT EXISTS endereco (
    id_endereco 		INT NOT NULL AUTO_INCREMENT,
    
    cep 				CHAR(8) NOT NULL,		-- XXXXX-XXX
    logradouro 			VARCHAR(120) NULL,		-- Avenida/Rua XPTO.
    bairro 				VARCHAR(60) NULL,		-- Bairro Abc.	
    localidade 			VARCHAR(60) NOT NULL,	-- São Paulo
    uf 					CHAR(2) NOT NULL,		-- SP
    numero 				VARCHAR(20) NULL,		-- XXXX
    complemento 		VARCHAR(60) NULL,
    km 					VARCHAR(20) NULL,		-- 54
    sentido 			VARCHAR(30) NULL,		-- Sul
    lat 				DECIMAL(10, 6) NULL,		-- -23.55XX
    lon 				DECIMAL(10, 6) NULL,		-- -46.63XX
    data_criacao 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao 	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY(id_endereco)
);

CREATE TABLE IF NOT EXISTS empresa (
    id_empresa 			INT NOT NULL AUTO_INCREMENT,
    endereco_id 		INT NULL,
    
    cnpj 				CHAR(14) NOT NULL UNIQUE,
    razao_social 		VARCHAR(120) NOT NULL,
    nome_fantasia 		VARCHAR(120) NOT NULL,
    email 				VARCHAR(120) NOT NULL UNIQUE,

    -- Dados da empresa para integrar com o Jira
    jira_email          VARCHAR(120) NULL,
    jira_base_url       VARCHAR(255) NULL,
    jira_project_key    VARCHAR(10)  NULL,
    jira_api_key        VARCHAR(255) NULL,

    data_criacao 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao 	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id_empresa),
    CONSTRAINT fk_empresa_endereco
        FOREIGN KEY (endereco_id) REFERENCES endereco(id_endereco)
);

CREATE TABLE IF NOT EXISTS embarcado (
    id_embarcado 		INT NOT NULL AUTO_INCREMENT,
    empresa_id 			INT NOT NULL,
    endereco_id 		INT NOT NULL,
    
    endereco_mac 		CHAR(17) NOT NULL UNIQUE,
    apelido 			VARCHAR(60) NOT NULL,
    modelo 				VARCHAR(60) NOT NULL,
    status 				TINYINT(1) NOT NULL DEFAULT 1,
    data_criacao 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao 	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id_embarcado, empresa_id),
    CONSTRAINT fk_embarcado_empresa
        FOREIGN KEY (empresa_id) REFERENCES empresa(id_empresa) ON DELETE CASCADE,
	CONSTRAINT fk_embarcado_endereco
        FOREIGN KEY (endereco_id) REFERENCES endereco(id_endereco)
);

CREATE TABLE IF NOT EXISTS componente (
    id_componente INT NOT NULL AUTO_INCREMENT,
    
    nome 				VARCHAR(60) NOT NULL UNIQUE,
    descricao           VARCHAR(120) NOT NULL,
    unidade_medida 		VARCHAR(20) NOT NULL,
    depende_de			VARCHAR(60) NOT NULL,
    data_criacao 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao 	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id_componente)
);

CREATE TABLE IF NOT EXISTS parametro (
    embarcado_id 		INT NOT NULL,
    empresa_id 			INT NOT NULL,
    componente_id 		INT NOT NULL,
    
    status 				TINYINT(1) NOT NULL DEFAULT 1,
    limite_max 			DECIMAL(10,3) NULL,
    limite_min 			DECIMAL(10,3) NULL,
    data_criacao 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao 	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
	PRIMARY KEY (embarcado_id, empresa_id, componente_id),
    CONSTRAINT fk_parametro_embarcado
        FOREIGN KEY (embarcado_id, empresa_id) REFERENCES embarcado(id_embarcado, empresa_id) ON DELETE CASCADE,
    CONSTRAINT fk_parametro_componente
        FOREIGN KEY (componente_id) REFERENCES componente(id_componente)
);

CREATE TABLE IF NOT EXISTS usuario (
    id_usuario 			INT NOT NULL AUTO_INCREMENT,
    empresa_id 			INT NOT NULL,
    supervisor_id 		INT NULL,
    
    nome 				VARCHAR(120) NOT NULL,
    email 				VARCHAR(120) NOT NULL UNIQUE,
    senha 				VARCHAR(255) NOT NULL,
    nivel_acesso 		TINYINT(1) NOT NULL DEFAULT 2, -- considerando: 0 - dev | 1 - adm | 2 - usr comum
    data_criacao 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao 	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY(id_usuario),
    CONSTRAINT fk_usuario_empresa
        FOREIGN KEY (empresa_id) REFERENCES empresa(id_empresa),
    CONSTRAINT fk_usuario_supervisor
        FOREIGN KEY (supervisor_id) REFERENCES usuario(id_usuario)
);

CREATE TABLE IF NOT EXISTS log_usuario (
    id_log				INT NOT NULL AUTO_INCREMENT,
    usuario_id 			INT NOT NULL,

    acao 				VARCHAR(255) NOT NULL,
    data_criacao 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id_log, usuario_id),
    CONSTRAINT fk_log_usuario_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario(id_usuario)
);

CREATE TABLE IF NOT EXISTS codigo_acesso (
    id_codigo 		INT NOT NULL AUTO_INCREMENT,
    usuario_id		INT NOT NULL,
    empresa_id 		INT NOT NULL,

    codigo 			CHAR(12) NOT NULL UNIQUE,
    status 			VARCHAR(20) NOT NULL DEFAULT "valido",
    qtd_usos_max 	INTEGER NOT NULL DEFAULT 1,
    qtd_usos		INTEGER NOT NULL DEFAULT 0,

	data_expiracao	DATETIME NOT NULL,   
	data_criacao 	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   
    PRIMARY KEY(id_codigo, usuario_id, empresa_id),
    CONSTRAINT fk_codigo_acesso_usuario
		FOREIGN KEY (usuario_id) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_codigo_acesso_empresa
        FOREIGN KEY (empresa_id) REFERENCES empresa(id_empresa),
        
    CONSTRAINT chk_codigo_autenticacao_status
		CHECK(status IN("valido", "usado", "expirado"))
);

-- | CRIAÇÃO DAS VIEWS | --

-- VW01: Retorna uma lista de embarcados com seus componentes monitorados + parametrizações
CREATE OR REPLACE VIEW vw_componentes_monitorados
AS
SELECT 
	e.id_embarcado, e.empresa_id, e.endereco_mac, e.apelido AS "servidor", 
    c.nome AS "componente", c.unidade_medida, c.depende_de, 
    p.limite_max, p.limite_min
FROM embarcado e 
JOIN parametro p
	ON e.id_embarcado = p.embarcado_id AND e.empresa_id = p.empresa_id
JOIN componente c
	ON p.componente_id = c.id_componente
WHERE e.status <> 0 AND p.status <> 0;