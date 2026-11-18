-- Schema inicial da Florama para uma instalação nova no Render Postgres.
-- Pode ser executado novamente sem duplicar as categorias e produtos iniciais.
BEGIN;

CREATE TABLE IF NOT EXISTS public.categorias (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  nome text NOT NULL,
  ordem integer NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS public.produtos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  categoria_id uuid NOT NULL REFERENCES public.categorias(id),
  nome text NOT NULL,
  descricao text NOT NULL,
  preco numeric(10, 2) NOT NULL CHECK (preco > 0),
  emoji text NOT NULL,
  cor_fundo char(7) NOT NULL,
  ativo boolean NOT NULL DEFAULT true,
  UNIQUE (categoria_id, nome)
);

CREATE TABLE IF NOT EXISTS public.perfis (
  id uuid PRIMARY KEY,
  nome text NOT NULL,
  email text NOT NULL,
  telefone text,
  endereco text,
  senha_hash text,
  papel text NOT NULL DEFAULT 'cliente',
  criado_em timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS perfis_email_lower_uidx
  ON public.perfis (lower(email));

CREATE TABLE IF NOT EXISTS public.favoritos (
  usuario_id uuid NOT NULL REFERENCES public.perfis(id) ON DELETE CASCADE,
  produto_id uuid NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE,
  criado_em timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (usuario_id, produto_id)
);

CREATE TABLE IF NOT EXISTS public.carrinhos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id uuid NOT NULL REFERENCES public.perfis(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'ativo',
  criado_em timestamptz NOT NULL DEFAULT now(),
  CHECK (status IN ('ativo', 'convertido'))
);
CREATE UNIQUE INDEX IF NOT EXISTS carrinhos_usuario_ativo_uidx
  ON public.carrinhos (usuario_id) WHERE status = 'ativo';

CREATE TABLE IF NOT EXISTS public.itens_carrinho (
  carrinho_id uuid NOT NULL REFERENCES public.carrinhos(id) ON DELETE CASCADE,
  produto_id uuid NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE,
  quantidade integer NOT NULL CHECK (quantidade BETWEEN 1 AND 99),
  PRIMARY KEY (carrinho_id, produto_id)
);

CREATE TABLE IF NOT EXISTS public.vendas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id uuid NOT NULL REFERENCES public.perfis(id),
  status text NOT NULL DEFAULT 'aguardando_pagamento',
  forma_pagamento text,
  status_pagamento text NOT NULL DEFAULT 'pendente',
  subtotal numeric(10, 2) NOT NULL CHECK (subtotal >= 0),
  taxa_entrega numeric(10, 2) NOT NULL DEFAULT 0 CHECK (taxa_entrega >= 0),
  total numeric(10, 2) NOT NULL CHECK (total >= 0),
  nome_recebedor text,
  telefone_recebedor text,
  endereco_entrega text,
  criado_em timestamptz NOT NULL DEFAULT now(),
  CHECK (status IN ('aguardando_pagamento', 'paga', 'em_preparo', 'pronta_entrega', 'concluida', 'cancelada')),
  CHECK (status_pagamento IN ('pendente', 'aprovado'))
);

CREATE TABLE IF NOT EXISTS public.itens_venda (
  id bigserial PRIMARY KEY,
  venda_id uuid NOT NULL REFERENCES public.vendas(id) ON DELETE CASCADE,
  produto_id uuid REFERENCES public.produtos(id) ON DELETE SET NULL,
  nome_produto text NOT NULL,
  descricao_produto text NOT NULL,
  preco_unitario numeric(10, 2) NOT NULL CHECK (preco_unitario >= 0),
  quantidade integer NOT NULL CHECK (quantidade BETWEEN 1 AND 99)
);

INSERT INTO public.categorias (slug, nome, ordem) VALUES
  ('rosas', 'Rosas', 1),
  ('tulipas', 'Tulipas', 2),
  ('girassois', 'Girassóis', 3),
  ('lirios', 'Lírios', 4),
  ('margaridas', 'Margaridas', 5),
  ('gerberas', 'Gérberas', 6),
  ('orquideas', 'Orquídeas', 7),
  ('buques', 'Buquês', 8)
ON CONFLICT (slug) DO UPDATE SET nome = EXCLUDED.nome, ordem = EXCLUDED.ordem;

INSERT INTO public.produtos (categoria_id, nome, descricao, preco, emoji, cor_fundo)
SELECT c.id, p.nome, p.descricao, p.preco, p.emoji, p.cor_fundo
FROM (VALUES
  ('rosas', 'Monalisa', '1 rosa', 15.00, '🌹', '#f5e9e8'),
  ('rosas', 'Triana', '3 rosas', 30.00, '🌹', '#f5e9e8'),
  ('rosas', 'Septália', '7 rosas', 65.00, '🌹', '#f5e9e8'),
  ('rosas', 'Década', '10 rosas', 90.00, '🌹', '#f5e9e8'),
  ('rosas', 'Donzela', '12 rosas', 110.00, '🌹', '#f5e9e8'),
  ('rosas', 'Quinzel', '15 rosas', 130.00, '🌹', '#f5e9e8'),
  ('rosas', 'Octelle', '18 rosas', 155.00, '🌹', '#f5e9e8'),
  ('tulipas', 'Primavera', '1 tulipa', 15.00, '🌷', '#edf1e8'),
  ('tulipas', 'Turban', '3 tulipas', 30.00, '🌷', '#edf1e8'),
  ('tulipas', 'Holanda', '7 tulipas', 65.00, '🌷', '#edf1e8'),
  ('tulipas', 'Tulipar', '10 tulipas', 90.00, '🌷', '#edf1e8'),
  ('tulipas', 'Jardim', '12 tulipas', 110.00, '🌷', '#edf1e8'),
  ('tulipas', 'Amsterdam', '15 tulipas', 130.00, '🌷', '#edf1e8'),
  ('tulipas', 'Campo', '18 tulipas', 155.00, '🌷', '#edf1e8'),
  ('girassois', 'Solitário Dourado', '1 girassol', 20.00, '🌻', '#fff2d8'),
  ('girassois', 'Trio Solar', '3 girassóis', 55.00, '🌻', '#fff2d8'),
  ('girassois', 'Campo de Sol', '5 girassóis', 85.00, '🌻', '#fff2d8'),
  ('lirios', 'Lírio Elegance', '1 haste', 25.00, '🌸', '#f5edf1'),
  ('lirios', 'Duo de Lírios', '2 hastes', 48.00, '🌸', '#f5edf1'),
  ('lirios', 'Lírios em Flor', '3 hastes', 70.00, '🌸', '#f5edf1'),
  ('margaridas', 'Margaridas do Campo', '6 flores', 35.00, '🌼', '#f7f3df'),
  ('margaridas', 'Jardim de Margaridas', '12 flores', 60.00, '🌼', '#f7f3df'),
  ('gerberas', 'Gérbera Clássica', '1 flor', 15.00, '🌺', '#f8e9e6'),
  ('gerberas', 'Mix Colorido', '6 gérberas', 70.00, '🌺', '#f8e9e6'),
  ('orquideas', 'Mini Orquídea', 'Planta em vaso', 75.00, '🪴', '#f1eaf5'),
  ('orquideas', 'Orquídea Phalaenopsis', 'Planta em vaso', 120.00, '🪴', '#f1eaf5'),
  ('buques', 'Rosa Adormecida', 'Buquê artesanal em cetim', 70.00, '💐', '#f3eaf0'),
  ('buques', 'Rosa de Ouro', 'Buquê artesanal em cetim', 70.00, '💐', '#f3eee0'),
  ('buques', 'Aurora', 'Composição de rosas e tulipas', 130.00, '💐', '#f3eaf0'),
  ('buques', 'Sol da Manhã', 'Composição de girassóis', 110.00, '💐', '#fff2d8'),
  ('buques', 'Jardim Colorido', 'Composição de gérberas e margaridas', 115.00, '💐', '#f7f0e6'),
  ('buques', 'Brisa', 'Composição de lírios', 95.00, '💐', '#f5edf1'),
  ('buques', 'Romance Vermelho', 'Composição de rosas', 135.00, '💐', '#f5e9e8'),
  ('buques', 'Primavera Mix', 'Composição de tulipas e folhagens', 105.00, '💐', '#edf1e8')
) AS p(slug, nome, descricao, preco, emoji, cor_fundo)
JOIN public.categorias c ON c.slug = p.slug
ON CONFLICT (categoria_id, nome) DO UPDATE
SET descricao = EXCLUDED.descricao,
    preco = EXCLUDED.preco,
    emoji = EXCLUDED.emoji,
    cor_fundo = EXCLUDED.cor_fundo,
    ativo = true;

COMMIT;
