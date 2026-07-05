-- MyTown dataset — sample queries
-- Load: gunzip mytown.db.gz && sqlite3 mytown.db

-- Coverage by state/province
SELECT country, state, COUNT(*) AS towns
FROM municipalities GROUP BY country, state ORDER BY towns DESC;

-- The busiest councils (most meetings tracked)
SELECT mu.name, mu.state, COUNT(*) AS meetings
FROM meetings m JOIN municipalities mu ON mu.id = m.muni_id
GROUP BY mu.id ORDER BY meetings DESC LIMIT 25;

-- What did councils decide about housing in the last 30 days?
SELECT mu.name, mu.state, m.meeting_date, d.headline
FROM decisions d
JOIN meetings m ON m.id = d.meeting_id
JOIN municipalities mu ON mu.id = m.muni_id
WHERE d.tags LIKE '%housing%' AND m.meeting_date >= date('now','-30 days')
ORDER BY m.meeting_date DESC;

-- Every vote tally mentioning a dollar amount (contract awards etc.)
SELECT mu.name, mu.state, m.meeting_date, j.value AS decision
FROM decisions d, json_each(d.decisions) j
JOIN meetings m ON m.id = d.meeting_id
JOIN municipalities mu ON mu.id = m.muni_id
WHERE j.value LIKE '%$%' AND j.value LIKE '%(%'
ORDER BY m.meeting_date DESC LIMIT 50;

-- Topic frequency across all briefs (rough trends)
SELECT lower(t.value) AS tag, COUNT(*) AS n
FROM briefs b, json_each(b.tags) t
GROUP BY 1 ORDER BY n DESC LIMIT 40;

-- Upcoming meetings with agendas, nationwide
SELECT mu.name, mu.state, m.meeting_date, m.body_name, b.headline
FROM meetings m
JOIN municipalities mu ON mu.id = m.muni_id
LEFT JOIN briefs b ON b.meeting_id = m.id
WHERE m.meeting_date >= date('now') AND m.agenda_url IS NOT NULL
ORDER BY m.meeting_date LIMIT 100;

-- Towns whose minutes we can read decisions from (transparency scorecard-ish)
SELECT mu.name, mu.state,
       COUNT(m.id) AS meetings,
       SUM(m.minutes_url IS NOT NULL) AS with_minutes,
       COUNT(d.meeting_id) AS with_decisions
FROM municipalities mu
JOIN meetings m ON m.muni_id = mu.id
LEFT JOIN decisions d ON d.meeting_id = m.id
GROUP BY mu.id HAVING meetings >= 10
ORDER BY with_decisions * 1.0 / meetings DESC LIMIT 25;
