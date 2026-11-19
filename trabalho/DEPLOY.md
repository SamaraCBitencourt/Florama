# Publicar a Florama no Render

O Blueprint na raiz do repositório configura a API (`florama-api`), o PostgreSQL (`florama-db`) e agora também o site web (`florama-site`). A API e o banco já foram criados. As etapas restantes são enviar a configuração web e sincronizar o Blueprint.

## 1. Enviar as alterações ao GitHub

No GitHub Desktop, confira e envie estas alterações:

- `render.yaml` na raiz do repositório;
- `trabalho/render.yaml`;
- `trabalho/app.json`;
- `trabalho/DEPLOY.md`.

Crie um commit e clique em **Push origin**. Não envie arquivos `.env` ou `.env.local`.

## 2. Criar o site no Render

1. Abra o Blueprint **FlorAma** no Render e clique em **Manual sync**.
2. Confira que a sincronização vai criar `florama-site`. A configuração usa um site estático gratuito e compila o app Expo para web.
3. Aguarde o deploy de `florama-site` terminar. Abra a URL pública que o Render mostrar, por exemplo `https://florama-site.onrender.com`.
4. Teste o cadastro e a navegação. O site já recebe `EXPO_PUBLIC_API_URL=https://florama-api.onrender.com` durante a compilação, então não é necessário criar `.env.local` no Render.

O endereço `http://localhost:8081` continua servindo apenas para desenvolvimento no seu computador. Para alterar o endereço da API usado pelo site publicado, mude `EXPO_PUBLIC_API_URL` no `render.yaml` e envie uma nova alteração; o Render recompila o site.

## 3. Conferir a conta administradora

Se as migrações `001_auth_profile.sql` e `002_admin_payment_audit.sql` já foram executadas, crie uma conta pelo site. Depois, no Query Tool do pgAdmin conectado ao banco Render, promova essa conta:

```sql
UPDATE public.perfis
SET papel = 'admin'
WHERE lower(email) = lower('SEU-EMAIL-CADASTRADO')
RETURNING id, email, papel;
```

Confirme que somente a conta desejada voltou com `papel = admin`.

## Desenvolvimento local

Para que o app local use a API publicada, mantenha um `.env.local` na pasta do app, junto ao `package.json`:

```env
EXPO_PUBLIC_API_URL=https://florama-api.onrender.com
EXPO_PUBLIC_WHATSAPP_NUMBER=
```

Essas variáveis são públicas e podem ser incluídas no bundle web. Nunca coloque senhas ou chaves secretas em variáveis `EXPO_PUBLIC_`.

## Limite do banco gratuito

O PostgreSQL gratuito do Render expira 30 dias após a criação. Depois da expiração, há um prazo de 14 dias para fazer upgrade antes que o banco e os dados sejam excluídos. Consulte os [limites do plano gratuito do Render](https://render.com/docs/free).
