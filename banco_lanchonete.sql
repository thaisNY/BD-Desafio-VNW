-- 1. ESTRUTURA (CREATE TABLES)
CREATE TABLE cargos (id_cargo SERIAL PRIMARY KEY, nome_cargo VARCHAR(100), salario_base DECIMAL(10,2), permite_desc BOOLEAN);
CREATE TABLE categorias (id_categoria SERIAL PRIMARY KEY, nome_categoria VARCHAR(100));
CREATE TABLE clientes (id_cliente SERIAL PRIMARY KEY, nome VARCHAR(100), telefone VARCHAR(20), email VARCHAR(100));
CREATE TABLE fornecedores (id_fornecedor SERIAL PRIMARY KEY, nome_fantasia VARCHAR(100), cnpj_cpf VARCHAR(20), contato VARCHAR(50));
CREATE TABLE funcionarios (id_funcionario SERIAL PRIMARY KEY, id_cargo INT REFERENCES cargos(id_cargo), nome VARCHAR(100), cpf VARCHAR(14), data_admissao DATE, ativo BOOLEAN);
CREATE TABLE produtos (id_produto SERIAL PRIMARY KEY, id_categoria INT REFERENCES categorias(id_categoria), nome_produto VARCHAR(100), preco_venda DECIMAL(10,2));
CREATE TABLE insumos (id_insumo SERIAL PRIMARY KEY, id_fornecedor INT REFERENCES fornecedores(id_fornecedor), nome_insumo VARCHAR(100), unidade_medida VARCHAR(10), custo_unitario DECIMAL(10,2), qtd_estoque DECIMAL(10,3), est_minimo DECIMAL(10,3));
CREATE TABLE ficha_tecnica (id_ficha SERIAL PRIMARY KEY, id_produto INT REFERENCES produtos(id_produto), id_insumo INT REFERENCES insumos(id_insumo), qtd_necessaria DECIMAL(10,3));
CREATE TABLE estoque_mov (id_movimento SERIAL PRIMARY KEY, id_insumo INT REFERENCES insumos(id_insumo), tipo CHAR(1), quantidade DECIMAL(10,3), motivo VARCHAR(100), data_mov TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE pedidos (id_pedido SERIAL PRIMARY KEY, id_cliente INT REFERENCES clientes(id_cliente), id_atendente INT REFERENCES funcionarios(id_funcionario), data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP, status VARCHAR(30));
CREATE TABLE itens_pedido (id_item SERIAL PRIMARY KEY, id_pedido INT REFERENCES pedidos(id_pedido), id_produto INT REFERENCES produtos(id_produto), quantidade INT, preco_unitario DECIMAL(10,2));
CREATE TABLE pagamentos (id_pagamento SERIAL PRIMARY KEY, id_pedido INT REFERENCES pedidos(id_pedido), metodo VARCHAR(30), valor_pago DECIMAL(10,2));

-- 2. POVOAMENTO (SEM DADOS NULOS E COM MAIS VARIEDADE)

-- Cargos e Funcionários
INSERT INTO cargos (nome_cargo, salario_base, permite_desc) VALUES ('Gerente', 4000.00, true), ('Atendente', 1600.00, true), ('Cozinheiro', 2600.00, false);
INSERT INTO funcionarios (id_cargo, nome, cpf, data_admissao, ativo) VALUES 
(1, 'Ricardo Silva', '111.111.111-11', '2023-01-10', true), 
(2, 'Ana Oliveira', '222.222.222-22', '2023-05-20', true),
(3, 'Carlos Chef', '333.333.333-33', '2023-03-15', true);

-- Fornecedores Diversos
INSERT INTO fornecedores (nome_fantasia, cnpj_cpf, contato) VALUES 
('Frigorífico Boi Bom', '01.001/0001-01', '81-3721'),
('Panificadora Central', '02.002/0001-02', '81-3722'),
('Hortifruti da Villa', '03.003/0001-03', '81-3723'),
('Bebidas Express', '04.004/0001-04', '81-3724');

-- Categorias, Produtos e Insumos
INSERT INTO categorias (nome_categoria) VALUES ('Lanches'), ('Bebidas'), ('Salgados');

INSERT INTO produtos (id_categoria, nome_produto, preco_venda) VALUES 
(1, 'X-Salada Premium', 28.50), (2, 'Suco de Laranja', 12.00), (3, 'Coxinha de Frango', 8.50);

INSERT INTO insumos (id_fornecedor, nome_insumo, unidade_medida, custo_unitario, qtd_estoque, est_minimo) VALUES 
(1, 'Hamburguer 150g', 'un', 5.00, 100, 20),
(2, 'Pao de Gergelim', 'un', 1.50, 100, 20),
(3, 'Tomate fatiado', 'kg', 8.00, 10, 2),
(3, 'Alface Americana', 'un', 4.00, 15, 5),
(1, 'Frango Desfiado', 'kg', 18.00, 20, 5),
(2, 'Massa de Salgado', 'kg', 10.00, 30, 5);

-- Fichas Técnicas (Produtos com vários ingredientes)
-- X-Salada: Pão, Carne, Tomate, Alface
INSERT INTO ficha_tecnica (id_produto, id_insumo, qtd_necessaria) VALUES 
(1, 1, 1), (1, 2, 1), (1, 3, 0.05), (1, 4, 0.1); 
-- Coxinha: Massa, Frango
INSERT INTO ficha_tecnica (id_produto, id_insumo, qtd_necessaria) VALUES 
(3, 5, 0.05), (3, 6, 0.1);

-- Clientes
INSERT INTO clientes (nome, telefone) VALUES 
('João', '91'), ('Maria', '92'), ('Lucas', '93'), ('Bia', '94'), ('Ana', '95'), 
('Rod', '96'), ('Cris', '97'), ('Dani', '98'), ('Enzo', '99'), ('Carla', '90');

-- 20 Pedidos Variados
INSERT INTO pedidos (id_cliente, id_atendente, status) 
SELECT (CASE WHEN i <= 10 THEN i ELSE i-10 END), 2, 'Finalizado' FROM generate_series(1, 20) AS s(i);

-- Itens de Pedido Variados (Uns pedem lanche, outros pedem coxinha)
INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario) 
SELECT id_pedido, 3, 2, 8.50 FROM pedidos WHERE id_pedido % 2 = 0; -- Pedidos pares: Coxinha
INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario) 
SELECT id_pedido, 1, 1, 28.50 FROM pedidos WHERE id_pedido % 2 <> 0; -- Pedidos ímpares: X-Salada

-- Pagamentos
INSERT INTO pagamentos (id_pedido, metodo, valor_pago) 
SELECT id_pedido, 'Cartão', (SELECT SUM(quantidade * preco_unitario) FROM itens_pedido WHERE id_pedido = p.id_pedido) 
FROM pedidos p;