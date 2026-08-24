-- ============================================================================
-- OSA - OFFICIAL SHOP ADMINISTRATOR (MERCADO NOVA VIDA)
-- BANCO DE DADOS SUPABASE (POSTGRESQL) - SCHEMA COMPLETO DDL & DML
-- ============================================================================

-- 1. TABELA DE CATEGORIAS / DEPARTAMENTOS
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABELA DE PRODUTOS
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  barcode TEXT,
  name TEXT NOT NULL,
  category_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
  unit TEXT NOT NULL DEFAULT 'un',
  cost_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
  selling_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
  markup_percent NUMERIC(8, 2) DEFAULT 0,
  stock_warehouse NUMERIC(12, 3) NOT NULL DEFAULT 0,
  stock_store NUMERIC(12, 3) NOT NULL DEFAULT 0,
  min_stock NUMERIC(12, 3) NOT NULL DEFAULT 5,
  location_warehouse TEXT,
  location_store TEXT,
  supplier_name TEXT,
  invoice_ref TEXT,
  notes TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para pesquisa ultra-rápida de produtos
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_code ON products(code);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);

-- 3. TABELA DE PERFIS DE UTILIZADORES (RBAC)
CREATE TABLE IF NOT EXISTS user_profiles (
  id TEXT PRIMARY KEY,
  auth_user_id UUID,
  username TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'junior_admin', 'cashier')),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TABELA DE MOVIMENTAÇÕES DE ESTOQUE
CREATE TABLE IF NOT EXISTS stock_movements (
  id TEXT PRIMARY KEY,
  product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  movement_type TEXT NOT NULL CHECK (movement_type IN ('entry', 'transfer_wh_to_store', 'transfer_store_to_wh', 'sale', 'adjustment_loss', 'adjustment_surplus', 'inventory_correction')),
  quantity NUMERIC(12, 3) NOT NULL,
  source_location TEXT NOT NULL,
  destination_location TEXT NOT NULL,
  previous_stock_warehouse NUMERIC(12, 3) DEFAULT 0,
  new_stock_warehouse NUMERIC(12, 3) DEFAULT 0,
  previous_stock_store NUMERIC(12, 3) DEFAULT 0,
  new_stock_store NUMERIC(12, 3) DEFAULT 0,
  unit_cost NUMERIC(12, 2) DEFAULT 0,
  total_cost NUMERIC(12, 2) DEFAULT 0,
  reference_doc TEXT,
  supplier_name TEXT,
  user_id TEXT,
  user_name TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TABELA DE TRANSFERÊNCIAS INTERNAS
CREATE TABLE IF NOT EXISTS internal_transfers (
  id TEXT PRIMARY KEY,
  transfer_number TEXT NOT NULL UNIQUE,
  from_location TEXT NOT NULL,
  to_location TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'completed',
  total_items INT NOT NULL DEFAULT 1,
  user_name TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. TABELA DE VENDAS (POS)
CREATE TABLE IF NOT EXISTS sales (
  id TEXT PRIMARY KEY,
  sale_number TEXT NOT NULL UNIQUE,
  subtotal_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  discount_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  net_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('dinheiro', 'mpesa', 'emola', 'cartao_pos', 'misto')),
  amount_tendered NUMERIC(12, 2) DEFAULT 0,
  change_amount NUMERIC(12, 2) DEFAULT 0,
  customer_name TEXT,
  customer_nuit TEXT,
  user_id TEXT,
  cashier_name TEXT NOT NULL,
  cash_register_id TEXT,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. TABELA DE SESSÕES DE CAIXA
CREATE TABLE IF NOT EXISTS cash_registers (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  user_name TEXT NOT NULL,
  opening_balance NUMERIC(12, 2) NOT NULL DEFAULT 0,
  closing_balance NUMERIC(12, 2),
  cash_sales NUMERIC(12, 2) DEFAULT 0,
  mpesa_sales NUMERIC(12, 2) DEFAULT 0,
  emola_sales NUMERIC(12, 2) DEFAULT 0,
  card_sales NUMERIC(12, 2) DEFAULT 0,
  total_sales NUMERIC(12, 2) DEFAULT 0,
  cash_in NUMERIC(12, 2) DEFAULT 0,
  cash_out NUMERIC(12, 2) DEFAULT 0,
  difference NUMERIC(12, 2) DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed')),
  opened_at TIMESTAMPTZ DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  notes TEXT
);

-- 8. TABELA DE INVENTÁRIOS FÍSICOS
CREATE TABLE IF NOT EXISTS inventory_sessions (
  id TEXT PRIMARY KEY,
  session_number TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  target_location TEXT NOT NULL DEFAULT 'all',
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'applied', 'cancelled')),
  total_products_audited INT DEFAULT 0,
  total_discrepancies INT DEFAULT 0,
  total_financial_loss NUMERIC(12, 2) DEFAULT 0,
  total_financial_surplus NUMERIC(12, 2) DEFAULT 0,
  user_id TEXT,
  responsible_user TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  applied_at TIMESTAMPTZ
);

-- 9. TABELA DE ITENS DO INVENTÁRIO
CREATE TABLE IF NOT EXISTS inventory_session_items (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES inventory_sessions(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL REFERENCES products(id),
  product_code TEXT NOT NULL,
  product_name TEXT NOT NULL,
  category_name TEXT,
  system_stock_warehouse NUMERIC(12, 3) DEFAULT 0,
  system_stock_store NUMERIC(12, 3) DEFAULT 0,
  counted_stock_warehouse NUMERIC(12, 3) DEFAULT 0,
  counted_stock_store NUMERIC(12, 3) DEFAULT 0,
  difference_warehouse NUMERIC(12, 3) DEFAULT 0,
  difference_store NUMERIC(12, 3) DEFAULT 0,
  cost_price NUMERIC(12, 2) DEFAULT 0,
  financial_impact NUMERIC(12, 2) DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending',
  notes TEXT,
  counted_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. TABELA DE COMBUSTÍVEL, FROTAS E GERADORES
CREATE TABLE IF NOT EXISTS fuel_records (
  id TEXT PRIMARY KEY,
  record_number TEXT NOT NULL UNIQUE,
  vehicle_or_equipment TEXT NOT NULL,
  fuel_type TEXT NOT NULL DEFAULT 'diesel' CHECK (fuel_type IN ('diesel', 'gasolina', 'gas')),
  liters NUMERIC(10, 2) NOT NULL,
  price_per_liter NUMERIC(10, 2) NOT NULL,
  total_cost NUMERIC(12, 2) NOT NULL,
  current_km_hours NUMERIC(12, 2),
  driver_responsible TEXT NOT NULL,
  fuel_station TEXT NOT NULL,
  invoice_ref TEXT,
  user_name TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. TABELA DE FECHAMENTO DO DIA
CREATE TABLE IF NOT EXISTS daily_closings (
  id TEXT PRIMARY KEY,
  closing_date DATE NOT NULL UNIQUE,
  gross_sales NUMERIC(12, 2) NOT NULL DEFAULT 0,
  net_sales NUMERIC(12, 2) NOT NULL DEFAULT 0,
  cash_total NUMERIC(12, 2) NOT NULL DEFAULT 0,
  mpesa_total NUMERIC(12, 2) NOT NULL DEFAULT 0,
  emola_total NUMERIC(12, 2) NOT NULL DEFAULT 0,
  card_total NUMERIC(12, 2) NOT NULL DEFAULT 0,
  total_transactions INT NOT NULL DEFAULT 0,
  auditor_user TEXT NOT NULL,
  auditor_role TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- DADOS INICIAIS (SEEDS) - CATEGORIAS, PRODUTOS E USUÁRIOS
-- ============================================================================

INSERT INTO categories (id, name, description) VALUES
  ('cat-1', 'Alimentação & Cereais', 'Arroz, Farinha, Açúcar, Massas e Cereais'),
  ('cat-2', 'Bebidas & Sumos', 'Refrigerantes, Águas, Sumos e Cervejas'),
  ('cat-3', 'Higiene & Limpeza', 'Sabão, Detergentes, Papel Higiênico e Desinfetantes'),
  ('cat-4', 'Laticínios & Frios', 'Leites, Manteigas, Queijos e Iogurtes'),
  ('cat-5', 'Enlatados & Óleos', 'Óleos de Cozinha, Sardinhas, Atum e Tomate')
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_profiles (id, username, full_name, role) VALUES
  ('usr-admin', 'admin', 'Administrador Geral', 'admin'),
  ('usr-junior', 'junior', 'Júnior Admin - Gestor de Estoque', 'junior_admin'),
  ('usr-caixa', 'caixa1', 'Operador de Caixa 01', 'cashier')
ON CONFLICT (id) DO NOTHING;

INSERT INTO products (
  id, code, name, category_id, unit, cost_price, selling_price, markup_percent,
  stock_warehouse, stock_store, min_stock, location_warehouse, location_store
) VALUES
  ('prod-1', 'ARR-25K', 'Arroz Mariana 25Kg', 'cat-1', 'saco', 1150.00, 1380.00, 20, 120, 35, 10, 'Corredor A-01', 'Gôndola 01'),
  ('prod-2', 'FAR-05K', 'Farinha de Milho Top 5Kg', 'cat-1', 'saco', 240.00, 295.00, 23, 85, 20, 8, 'Corredor A-02', 'Gôndola 01'),
  ('prod-3', 'OLE-01L', 'Óleo de Cozinha Mariana 1L', 'cat-5', 'garrafa', 110.00, 135.00, 22.7, 200, 48, 15, 'Corredor B-01', 'Gôndola 03'),
  ('prod-4', 'ACU-01K', 'Açúcar Castanho Maragra 1Kg', 'cat-1', 'pacote', 72.00, 88.00, 22.2, 300, 60, 20, 'Corredor A-03', 'Gôndola 02'),
  ('prod-5', 'LEI-01L', 'Leite Longa Vida Integral 1L', 'cat-4', 'un', 85.00, 105.00, 23.5, 140, 30, 10, 'Corredor C-01', 'Gôndola 04'),
  ('prod-6', 'SAB-01K', 'Sabão em Barra Omo 1Kg', 'cat-3', 'barra', 65.00, 80.00, 23, 180, 40, 12, 'Corredor D-01', 'Gôndola 05'),
  ('prod-7', 'REF-2L', 'Refrigerante Coca-Cola 2L', 'cat-2', 'garrafa', 105.00, 130.00, 23.8, 150, 45, 12, 'Corredor B-02', 'Gôndola 02')
ON CONFLICT (id) DO NOTHING;

-- Habilitar RLS nas tabelas principais
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_sessions ENABLE ROW LEVEL SECURITY;

-- Políticas de Acesso Público para Leitura e Escrita
CREATE POLICY "Public full access categories" ON categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public full access products" ON products FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public full access stock_movements" ON stock_movements FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public full access sales" ON sales FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public full access inventory_sessions" ON inventory_sessions FOR ALL USING (true) WITH CHECK (true);
