# Publicar a Florama no Render

O arquivo `render.yaml` prepara uma API FastAPI e um PostgreSQL no Render. O Blueprint cria os dois serviços e conecta o banco à API automaticamente. A publicação ainda exige acesso à sua conta Render e ao repositório GitHub.

## 1. Enviar o projeto ao GitHub

1. Abra `Phil-Souza/Florama` no GitHub e confira se o conteúdo desta pasta (`trabalho`) está na raiz do repositório, incluindo `render.yaml`.
2. Se ainda não estiver no GitHub, crie um repositório e envie o conteúdo da pasta `trabalho`. Não envie arquivos `.env` nem senhas.

## 2. Criar API e banco no Render

1. Entre no Render e escolha **New → Blueprint**.
2. Conecte o repositório GitHub que contém `render.yaml` e confirme a criação dos recursos `florama-api` e `florama-db`.
3. O Blueprint gera o `JWT_SECRET` e preenche `DATABASE_URL` com a conexão privada ao PostgreSQL.
4. Quando o deploy terminar, abra `florama-db` no Render e copie a **External Database URL**. No pgAdmin, crie uma conexão PostgreSQL usando os dados dessa URL: host, porta, nome do banco, usuário e senha.
5. No pgAdmin, abra o Query Tool nessa conexão. Abra e execute com **F5** estes arquivos, um por vez e nesta ordem: `api/migrations/000_initial_schema.sql`, `api/migrations/001_auth_profile.sql` e `api/migrations/002_admin_payment_audit.sql`. O primeiro cria as tabelas e carrega o catálogo inicial; os outros dois preparam cadastro, autenticação e auditoria.
6. Abra a URL pública de `florama-api` seguida de `/health`. A resposta esperada é `{"status":"ok","database":"connected"}`.

**Atenção ao plano gratuito:** o PostgreSQL gratuito do Render expira após 30 dias. Depois da expiração, há 14 dias para fazer upgrade antes da exclusão do banco e dos dados. Se precisar manter os dados por mais tempo, faça upgrade do banco no Render antes do prazo ou exporte um backup.

## 3. Apontar o app para a API

Na pasta do app (`trabalho`), crie ou edite `.env.local`:

```env
EXPO_PUBLIC_API_URL=https://SUA-URL-DA-API.onrender.com
EXPO_PUBLIC_WHATSAPP_NUMBER=
```

Substitua pela URL pública exibida pelo Render. O número de WhatsApp é opcional; para habilitá-lo, use DDI + DDD + número, somente dígitos. Não coloque senhas ou chaves secretas em variáveis `EXPO_PUBLIC_`.

Para rodar o app localmente, na pasta `trabalho`, execute `npm install` e `npm run web`. Este Blueprint publica a API e o banco; publicar o app web é uma etapa separada.

## 4. Criar a conta administradora

Depois que as migrações forem executadas e a API estiver conectada ao banco, crie uma conta pelo app. No cliente SQL conectado ao banco Render, promova somente essa conta:

```sql
UPDATE public.perfis
SET papel = 'admin'
WHERE lower(email) = lower('SEU-EMAIL-CADASTRADO')
RETURNING id, email, papel;
```

Confirme que somente a conta desejada voltou com `papel = admin`.
