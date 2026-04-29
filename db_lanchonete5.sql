-- ==========================================================
-- CONSULTAS SIMPLES
-- ==========================================================

-- Ver todos os funcionários: 
SELECT * FROM Funcionarios;

-- Ver todos os produtos do cardápio: 
SELECT * FROM Produtos;

-- Listar insumos e seus estoques: 
SELECT nome_insumo, qtd_estoque FROM Insumos;

-- Ver clientes cadastrados: 
SELECT nome, email FROM Clientes;

-- Ver todos os pedidos feitos: 
SELECT * FROM Pedidos;

-- Ver quais categorias existem: 
SELECT * FROM Categorias;

-- Ver todos os fornecedores: 
SELECT * FROM Fornecedores;

-- Ver a lista de cargos e salários: 
SELECT nome_cargo, salario_base FROM Cargos;


-- ==========================================================
-- CONSULTAS COMPLEXAS
-- ==========================================================

-- 1) Em cada pedido o cliente, o que pediu, a hora, quem atendeu, a forma de pagamento e etc. 
-- Resumindo: registro financeiro do caixa.

SELECT 
    p.id_pedido AS "Nº Pedido",
    p.data_hora AS "Data/Hora",
    c.nome AS "Cliente",
    prod.nome_produto AS "Produto",
    ip.quantidade AS "Qtd",
    ip.preco_unitario AS "Preço Unit.",
    (ip.quantidade * ip.preco_unitario) AS "Total Item",
    f.nome AS "Atendente",
    pag.metodo AS "Forma de Pagto"
FROM Pedidos p
INNER JOIN Clientes c ON p.id_cliente = c.id_cliente
INNER JOIN Funcionarios f ON p.id_atendente = f.id_funcionario
INNER JOIN Itens_Pedido ip ON p.id_pedido = ip.id_pedido
INNER JOIN Produtos prod ON ip.id_produto = prod.id_produto
INNER JOIN Pagamentos pag ON p.id_pedido = pag.id_pedido;


-- 2) A ficha técnica (receita) de cada produto:

SELECT 
    p.nome_produto AS "Lanche",
    i.nome_insumo AS "Ingrediente",
    ft.qtd_necessaria AS "Quantidade",
    i.unidade_medida AS "Unidade"
FROM Ficha_Tecnica ft
INNER JOIN Produtos p ON ft.id_produto = p.id_produto
INNER JOIN Insumos i ON ft.id_insumo = i.id_insumo
ORDER BY p.nome_produto;


-- 3) Relatório financeiro: quanto custa cada produto, o preço de venda e o lucro:

SELECT 
    p.nome_produto AS "Lanche",
    SUM(ft.qtd_necessaria * i.custo_unitario) AS "Custo Total de Produção",
    p.preco_venda AS "Preço de Venda",
    (p.preco_venda - SUM(ft.qtd_necessaria * i.custo_unitario)) AS "Lucro Bruto"
FROM Ficha_Tecnica ft
INNER JOIN Produtos p ON ft.id_produto = p.id_produto
INNER JOIN Insumos i ON ft.id_insumo = i.id_insumo
GROUP BY p.nome_produto, p.preco_venda;


-- 4) O Fornecedor de cada insumo, o estoque atual e contato do fornecedor:

SELECT 
    i.nome_insumo AS "Insumo",
    i.unidade_medida AS "Unid.",
    f.nome_fantasia AS "Fornecedor",
    f.contato AS "Contato do Fornecedor",
    i.qtd_estoque AS "Estoque Atual"
FROM Insumos i
INNER JOIN Fornecedores f ON i.id_fornecedor = f.id_fornecedor
ORDER BY f.nome_fantasia;


-- 5) O que cada cliente pediu (limitado aos 10 primeiros resultados):

SELECT 
    c.nome AS "Cliente",
    p.id_pedido AS "Pedido",
    prod.nome_produto AS "Produto",
    ip.quantidade AS "Qtd",
    pag.valor_pago AS "Total Pedido"
FROM Clientes c
JOIN Pedidos p ON c.id_cliente = p.id_cliente
JOIN Itens_Pedido ip ON p.id_pedido = ip.id_pedido
JOIN Produtos prod ON ip.id_produto = prod.id_produto
JOIN Pagamentos pag ON p.id_pedido = pag.id_pedido
ORDER BY p.id_pedido LIMIT 10;