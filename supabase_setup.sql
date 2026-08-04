-- ============================================================
--  BEYOND INTERVIEW — Setup do banco (Supabase)
--  Rode este script inteiro no  SQL Editor  do Supabase
--  (menu lateral > SQL Editor > New query > cole tudo > Run).
-- ============================================================

-- 1) TABELA DE RESPOSTAS ------------------------------------
create table if not exists public.respostas (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz not null default now(),
  nome          text not null,
  email         text,
  tipo_projeto  text,
  respostas     jsonb not null default '{}'::jsonb
);

-- 2) LIGAR ROW LEVEL SECURITY --------------------------------
-- Com RLS ligado, NINGUÉM lê/escreve sem uma política explícita.
-- É isso que protege os dados mesmo com a anon key pública no código.
alter table public.respostas enable row level security;

-- 3) POLÍTICA DE INSERÇÃO (qualquer visitante pode responder) -
-- Permite que o formulário (usando a anon key) grave uma resposta.
-- 'anon' = visitante não logado. Só INSERT, nada de ler/editar.
drop policy if exists "qualquer um pode responder" on public.respostas;
create policy "qualquer um pode responder"
  on public.respostas
  for insert
  to anon, authenticated
  with check ( true );

-- 4) POLÍTICA DE LEITURA (somente o admin) -------------------
-- Só quem estiver logado com o e-mail do admin consegue ler.
-- Troque o e-mail abaixo se quiser mudar o administrador.
drop policy if exists "somente admin lê" on public.respostas;
create policy "somente admin lê"
  on public.respostas
  for select
  to authenticated
  using ( (auth.jwt() ->> 'email') = 'bryansf94@gmail.com' );

-- (Opcional) se quiser MAIS de um admin, use:
-- using ( (auth.jwt() ->> 'email') in ('bryansf94@gmail.com','outro@email.com') );

-- ============================================================
--  PRONTO. Agora falta criar o usuário admin (passo manual):
--
--  Authentication > Users > "Add user" > "Create new user"
--    E-mail:  bryansf94@gmail.com
--    Senha:   (escolha uma forte)
--    Marque "Auto Confirm User"  (pra não precisar confirmar e-mail)
--
--  Depois é só entrar no formulário em "Acesso da equipe"
--  com esse e-mail e senha.
-- ============================================================
