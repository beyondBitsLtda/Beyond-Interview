# Beyond Interview — o que mudou e como configurar

## O que já está pronto neste arquivo
- **Mascote novo** nas 3 poses (parado / andando / correndo), com fundo transparente, embutidas direto no HTML em base64 (nenhum arquivo de imagem solto pra se perder).
- **15 perguntas** (as 5 originais + 10 novas na mesma pegada do Beto).
- **Tela inicial de lead**: nome, e-mail (opcional) e tipo de projeto.
- **Gravação no Supabase** ao finalizar o papo.
- **Login opcional da equipe** (Supabase Auth) com **painel de respostas** só pro admin.

---

## Passo 1 — Criar o projeto no Supabase
1. Entre em https://supabase.com e crie um projeto (plano free serve).
2. Vá em **SQL Editor > New query**, cole todo o conteúdo de `supabase_setup.sql` e clique **Run**.
3. Crie o usuário admin: **Authentication > Users > Add user > Create new user**
   - E-mail: `bryansf94@gmail.com`
   - Senha: escolha uma forte
   - Marque **Auto Confirm User**

## Passo 2 — Pegar as credenciais
No Supabase: **Project Settings > API**. Copie:
- **Project URL** (algo como `https://xxxx.supabase.co`)
- **anon public** key (a chave longa marcada como `anon` / `public`)

> ⚠️ Nunca use a chave **service_role** aqui. Ela é secreta e daria acesso total.
> A `anon` é feita pra ser pública — a segurança está nas políticas RLS do banco.

## Passo 3 — Colar as credenciais no arquivo
Abra `Beyond_Interview_dc.html` e, no começo do `<script ... data-dc-script>`, edite:

```js
SUPABASE_URL  = 'https://SEU-PROJETO.supabase.co';   // <- sua Project URL
SUPABASE_ANON = 'COLE_AQUI_SUA_ANON_KEY';            // <- sua anon key
ADMIN_EMAIL   = 'bryansf94@gmail.com';               // <- e-mail do admin
```

### Sobre "environment variables na Vercel"
Você tinha pedido env vars na Vercel. Só que **site estático puro (HTML/JS)
não lê env vars da Vercel em tempo de execução** — isso só funciona em build
step (React/Next) ou em serverless functions. Por isso a URL e a anon key
ficam no código mesmo, e tudo bem: **essas duas são públicas por natureza**.
Quem realmente protege os dados é o RLS + o seu login. (Se um dia você migrar
pra um projeto com build ou usar uma função `/api`, aí sim dá pra mover essas
duas pra env vars — me chama que eu ajusto.)

## Passo 4 — Publicar na Vercel
Suba a pasta com os dois arquivos juntos (eles precisam ficar lado a lado):
- `Beyond_Interview_dc.html`
- `support.js`

Na Vercel: **Add New > Project**, arraste a pasta (ou conecte o repositório),
sem framework/preset (é estático), e faça o deploy.

---

## Como usar o painel de respostas
1. Na tela inicial, clique em **"Acesso da equipe"** (link discreto embaixo).
2. Entre com o e-mail e a senha do admin.
3. Você vê todas as respostas, com nome, tipo de projeto, e-mail e cada pergunta
   já traduzida (nada de códigos tipo `"quieta"` — aparece o texto completo).
4. Botão **Sair** encerra a sessão; **Atualizar** recarrega a lista.

Se alguém que não é o admin logar, o RLS simplesmente não devolve nenhuma
resposta — os dados ficam protegidos no banco.

## Estrutura da tabela `respostas`
| coluna         | tipo        | o que guarda                                  |
|----------------|-------------|-----------------------------------------------|
| `id`           | uuid        | id único (automático)                         |
| `created_at`   | timestamptz | data/hora do envio (automático)               |
| `nome`         | text        | nome que a pessoa digitou                      |
| `email`        | text        | e-mail (pode ser vazio)                        |
| `tipo_projeto` | text        | `landing`, `site`, `sistema`, `crm`, etc.     |
| `respostas`    | jsonb       | todas as 15 respostas, no formato `{id: valor}`|
