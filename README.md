# MyTown — open dataset of US & Canadian local-government meetings

Every city-council, board, and commission meeting we can find, machine-readable:
**2,300+ municipalities, ~50,000 meetings**, AI plain-English briefs of the agendas,
decisions extracted from official minutes (vote tallies, dollar amounts), Spanish/French
translations, and weekly town roundups. Built from the official meeting portals
(Legistar, CivicPlus, eScribe, CivicWeb, PrimeGov, CivicClerk) and refreshed daily.

Browse it as a website: [mytown.theboringparts.com](https://mytown.theboringparts.com) (US) ·
[canada.theboringparts.com](https://canada.theboringparts.com) (Canada) ·
part of [The Boring Parts](https://theboringparts.com).

**Why:** public records shouldn't need a subscription, a law degree, or a free afternoon
to read. The site is free; the data behind it is too.

## Download

One gzipped SQLite file, updated daily:

```bash
curl -LO https://archive.theboringparts.com/data/mytown.db.gz
gunzip mytown.db.gz
sqlite3 mytown.db '.tables'
```

Also mirrored on Hugging Face: [`jazzypajamas/mytown-local-gov-meetings`](https://huggingface.co/datasets/jazzypajamas/mytown-local-gov-meetings)

## Schema

| table | what it holds |
|---|---|
| `municipalities` | id, slug, name, state/province, country (`US`/`CA`), source platform |
| `meetings` | muni_id, body name, date/time, location, agenda/minutes/video URLs, `archived_pdf_key` |
| `briefs` | AI plain-English agenda summaries: headline, summary, notable_items (JSON), tags (JSON) |
| `decisions` | what passed/failed per official minutes: headline, summary, decisions (JSON, with tallies) |
| `briefs_i18n` | Spanish (`es`) and French (`fr`) translations of briefs |
| `roundups` | weekly newspaper-style roundups per town (markdown) |
| `about` | export date + license |

**Archived documents:** we mirror every agenda PDF we process. A meeting's
`archived_pdf_key` resolves to
`https://archive.theboringparts.com/<key>` — documents stay available
even after a city purges its portal.

## Sample queries

See [`queries.sql`](queries.sql). A taste:

```sql
-- What did councils decide about housing this month?
SELECT mu.name, mu.state, m.meeting_date, d.headline
FROM decisions d
JOIN meetings m ON m.id = d.meeting_id
JOIN municipalities mu ON mu.id = m.muni_id
WHERE d.tags LIKE '%housing%' AND m.meeting_date >= date('now','-30 days')
ORDER BY m.meeting_date DESC;
```

## Caveats

- Summaries and decisions are **AI-generated from official documents**. They are faithful
  in our testing, but verify against the linked agenda/minutes before relying on a detail.
- Coverage is broad, not complete: a town is present if it publishes on a platform we've
  adapted. Missing your town? Open an issue.
- Meeting metadata mirrors what cities publish — including their occasional typos.

## License

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Use it for research, journalism,
apps, or model training — credit **MyTown / theboringparts.com** with a link.
