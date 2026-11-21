
-- I01: Catálogo de componentes monitoráveis pelo cliente
INSERT INTO flowtech.componente(nome, descricao, unidade_medida, depende_de)
VALUES 
	('cpu_uso', 'Uso', 'pct', 'psutil.cpu_percent'),
	('cpu_freq', 'Frequência', 'MHz', 'psutil.cpu_freq'),
    ('ram_uso', 'Uso', 'pct', 'psutil.virtual_memory'),
    ('swap_uso', 'Uso', 'pct', 'psutil.swap_memory'),
    ('disco_uso', 'Armazenamento (Disco)', 'pct', 'psutil.disk_usage'),
    ('rede_download', 'Velocidade de Download', 'Mbps', 'psutil.net_io_counters'),
    ('rede_upload', 'Velocidade de Upload', 'Mbps', 'psutil.net_io_counters'),
    ('rede_latencia', 'Latência', 'ms', 'ping');
-- |/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\|

-- I02: Empresa e Usuário padrão da FlowTech (para uso interno)
SET @email = 'infra@flowtech.com.br';
SET @senha = 'FlowTech#2026';

INSERT INTO endereco(cep, logradouro, bairro, numero, complemento, localidade, uf)
	VALUES('01414001', 'Rua Haddock Lobo', 'Cerqueira César', '595', 'Edifício Digital Building, 2° andar - sala B', 'São Paulo', 'SP');

INSERT INTO empresa(endereco_id, cnpj, razao_social, nome_fantasia, email)
	VALUES (LAST_INSERT_ID(), '99999999999999', 'FlowTech - Soluções Tecnológicas', 'FlowTech', @email);

INSERT INTO usuario(empresa_id, nome, email, senha, nivel_acesso)
	VALUES (LAST_INSERT_ID(), 'FlowUser (Dev)', @email, SHA2(@senha, 256), 0);
-- |/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\|

-- I03: Empresa, Usuários e Embarcados padrão para as Personas(Kevin, Marcio, Vitória etc.)
SET @email_adm = 'contato@brvias.com.br';
SET @senha = 'BrVias#2026';

SET @jira_email = 'luizfernandolufe@yahoo.com.br'; 
SET @jira_base_url = 'https://luizfernandolufe.atlassian.net';
SET @jira_project_key = 'KAN';
SET @jira_api_key = 'ATATT3xFfGF0tG87_67cMvowO3flcQfSbTkV6CzdvZIBv20JCcz-lJJvpmt8syPM1OvUc1JjK2h9KOUap_tyDwUqeOpCIFCBeXVzNXaa8HMxRiHc7CSe-J-3Zk2xOtgq4S68cCEpvvGyFy6ko0ae94U99KWuGlI5qy993jELTrftJ6kbq16-Gks=F321FA03';


INSERT INTO endereco(cep, logradouro, bairro, numero, complemento, localidade, uf)
	VALUES('01001000', 'Praça da Sé', 'Sé', '999', 'lado ímpar', 'São Paulo', 'SP');

INSERT INTO empresa(endereco_id, cnpj, razao_social, nome_fantasia, email, jira_email, jira_base_url, jira_project_key, jira_api_key)
	VALUES (
    (SELECT id_endereco FROM endereco WHERE cep = '01001000' AND numero = '999' LIMIT 1), 
    '99999999999998', 'Brasil Operações Rodoviárias e Transporte', 'Vias do Brasil', @email_adm,
    @jira_email, @jira_base_url, @jira_project_key, @jira_api_key);

SET @id_empresa = (SELECT id_empresa FROM empresa WHERE cnpj = '99999999999998');
INSERT INTO usuario(empresa_id, nome, email, senha, nivel_acesso)
	VALUES 
    (@id_empresa, 'Usuário de Vias do Brasil (ADM)', @email_adm, SHA2(@senha, 256), 1),
    (@id_empresa, 'Kevin Augusto', 'kevin.augusto595@gmail.com', SHA2(@senha, 256), 1),
    (@id_empresa, 'Marcelo Poirot', 'poirotmarcelo@gmail.com', SHA2(@senha, 256), 1),
    (@id_empresa, 'Márcio Eduardo', 'marcio.eduardo@gmail.com', SHA2(@senha, 256), 2),
    (@id_empresa, 'Agatha Silva', 'silva.agatha@gmail.com', SHA2(@senha, 256), 2);

SET @id_adm = (SELECT id_usuario FROM usuario WHERE email = @email_adm);
SET @id_supervisor_kevin = (SELECT id_usuario FROM usuario WHERE email = 'kevin.augusto595@gmail.com');
UPDATE usuario 
	SET supervisor_id = @id_adm
WHERE email IN('kevin.augusto595@gmail.com', 'poirotmarcelo@gmail.com');
UPDATE usuario 
	SET supervisor_id = @id_supervisor_kevin
WHERE email IN('marcio.eduardo@gmail.com', 'silva.agatha@gmail.com');

INSERT INTO endereco(cep, logradouro, numero, localidade, uf, complemento, km, sentido, lat, lon)
	VALUES
    ('23810000', 'Rodovia Governador Mário Covas (BR-101)', 'S/N', 'Itaguaí', 
    'RJ', 'Pórtico Free Flow Km 414,9', '414.90', 'Leste/Oeste', -22.903889, -43.834444),
    
	('23860000', 'Rodovia Governador Mário Covas (BR-101)', 'S/N', 'Mangaratiba', 
    'RJ', 'Pórtico Free Flow Km 447,3', '447.30', 'Leste/Oeste', -23.006320, -44.099135),
    
	('02147090', 'Via Presidente Dutra (BR-116)', 'S/N', 'São Paulo', 
	'SP', 'Pórtico Free Flow Km 231', '231.00', 'Norte', -23.525000, -46.610784),

    ('14890500', 'Rodovia Carlos Tonani (SP-333)', '10', 'Jaboticabal', 
    'SP', 'Pórtico Free Flow Km 110', '110.00', 'Leste/Oeste', -21.228894, -48.235267),
    
    ('14900000', 'Rodovia Laurentino Mascari (SP-333)', '10', 'Itápolis', 
    'SP', 'Pórtico Free Flow Km 179', '179.00', 'Leste/Oeste', -21.543732, -48.789652),
    
	('09845000', 'Rodovia dos Imigrantes (SP-160)', 'S/N', 'Taquacetuba', 
    'SP', 'Pórtico Free Flow Km 29', '29.00', 'Leste/Oeste', -23.820747, -46.590464);

INSERT INTO embarcado(empresa_id, endereco_id, endereco_mac, apelido, modelo)
	VALUES (@id_empresa, (SELECT id_endereco FROM endereco WHERE cep = '23810000' LIMIT 1), '00:93:37:45:D2:B5', 'SRV-BR101-414', 'PADR-SR1980');
INSERT INTO parametro (embarcado_id, empresa_id, componente_id, status, limite_max, limite_min)
	VALUES 
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_freq'), 1, 3.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'ram_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'swap_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_download'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_upload'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_latencia'), 1, 200.000, NULL);

INSERT INTO embarcado(empresa_id, endereco_id, endereco_mac, apelido, modelo)
	VALUES (@id_empresa, (SELECT id_endereco FROM endereco WHERE cep = '23860000' LIMIT 1), '24:B2:B9:31:31:E5', 'SRV-BR101-447', 'PADR-SR1980');
INSERT INTO parametro (embarcado_id, empresa_id, componente_id, status, limite_max, limite_min)
	VALUES 
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_freq'), 1, 3.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'ram_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'swap_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_download'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_upload'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_latencia'), 1, 200.000, NULL);

INSERT INTO embarcado(empresa_id, endereco_id, endereco_mac, apelido, modelo)
	VALUES (@id_empresa, (SELECT id_endereco FROM endereco WHERE cep = '02147090' LIMIT 1), '50:FE:0C:25:F4:8D', 'SRV-BR116-231', 'PADR-SR1980');
INSERT INTO parametro (embarcado_id, empresa_id, componente_id, status, limite_max, limite_min)
	VALUES 
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_freq'), 1, 3.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'ram_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'swap_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_download'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_upload'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_latencia'), 1, 200.000, NULL);

INSERT INTO embarcado(empresa_id, endereco_id, endereco_mac, apelido, modelo)
	VALUES (@id_empresa, (SELECT id_endereco FROM endereco WHERE cep = '14890500' LIMIT 1), '5C:CD:5B:E5:3D:E1', 'SRV-BR333-110', 'PADR-SR1980');
INSERT INTO parametro (embarcado_id, empresa_id, componente_id, status, limite_max, limite_min)
	VALUES 
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_freq'), 1, 3.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'ram_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'swap_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_download'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_upload'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_latencia'), 1, 200.000, NULL);

INSERT INTO embarcado(empresa_id, endereco_id, endereco_mac, apelido, modelo)
	VALUES (@id_empresa, (SELECT id_endereco FROM endereco WHERE cep = '14900000' LIMIT 1), '8C:B0:E9:BC:12:F3', 'SRV-BR333-179', 'PADR-SR1980');
INSERT INTO parametro (embarcado_id, empresa_id, componente_id, status, limite_max, limite_min)
	VALUES 
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_freq'), 1, 3.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'ram_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'swap_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_download'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_upload'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_latencia'), 1, 200.000, NULL);

INSERT INTO embarcado(empresa_id, endereco_id, endereco_mac, apelido, modelo)
	VALUES (@id_empresa, (SELECT id_endereco FROM endereco WHERE cep = '09845000' LIMIT 1), 'DC:1B:A1:FE:BB:04', 'SRV-BR160-029', 'PADR-SR1980');
INSERT INTO parametro (embarcado_id, empresa_id, componente_id, status, limite_max, limite_min)
	VALUES 
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'cpu_freq'), 1, 3.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'ram_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'swap_uso'), 1, 90.000, NULL),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_download'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_upload'), 1, NULL, 4.500),
    (LAST_INSERT_ID(), @id_empresa, (SELECT id_componente FROM componente WHERE nome = 'rede_latencia'), 1, 200.000, NULL);
    
UPDATE embarcado
SET status = CASE apelido
    WHEN 'SRV-BR333-110' THEN 2  -- atenção
    WHEN 'SRV-BR101-414' THEN 2  -- atenção
    WHEN 'SRV-BR101-447' THEN 2  -- atenção
    WHEN 'SRV-BR333-179' THEN 0  -- crítico
    WHEN 'SRV-BR160-029' THEN 0  -- crítico
    ELSE 1                       -- controlado
END
WHERE empresa_id = (SELECT id_empresa FROM empresa WHERE cnpj = '99999999999998');
    
