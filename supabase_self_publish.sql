-- Sultan Associates: enable self-publishing for authenticated dealers and owners.
-- IMPORTANT: No tables or existing listings are deleted.
-- Requires email-confirmed authenticated accounts.
-- Before running, understand that spam and misleading property ads may become public.
begin;
-- Use a server-side default and allow authenticated inserts only for their own user ID.
alter table public.properties alter column status set default 'approved';
drop policy if exists "owner insert pending listings" on public.properties;
drop policy if exists "self publish own listing" on public.properties;
create policy "self publish own listing" on public.properties
for insert to authenticated
with check (
  owner_id=(select auth.uid())
  and status='approved'
  and (select auth.jwt()->>'email') is not null
);
commit;
-- Still recommended before inviting the public: anti-spam limits, reporting,
-- account verification and moderation tooling. Admin moderation function only
-- moderates pending listings; it must be extended for published-ad removal.
