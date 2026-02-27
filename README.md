# IPL-2025-SQL-Analysis-top-Batting
In Previous Quary I did not take strike rate for performance which is crucial for T20 Match. In this quary we will anlyse performance based on Total run performed, Average and Strike Rate as well
# IPL 2025 SQL Analysis

A ball-by-ball SQL analysis of the IPL 2025 season using delivery-level data. This project demonstrates real-world SQL skills including CTEs, conditional aggregation, and cricket specific calculations.

---

## Dataset

- Source: [Kaggle – IPL 2025 Ball by Ball Data](https://www.kaggle.com/) (https://www.kaggle.com/datasets/sahiltailor/cricket-ball-by-ball-dataset)
- Rows: ~17,000 deliveries
- Matches: 74 (Group Stage → Final)
- Columns: `match_id, season, phase, match_no, date, venue, batting_team, bowling_team, innings, over, striker, bowler, runs_of_bat, extras, wide, legbyes, byes, noballs, wicket_type, player_dismissed, fielder`

---

# Project Structure

```
ipl-2025-sql-analysis/
│
├── data/
│   └── ipl_2025_deliveries.csv
│
├── schema/
│   └── create_table.sql
│
├── queries/
│   ├── 01_batting_analysis.sql
│
└── README.md
```

---

#  Key SQL Concepts Used

- CTEs (`WITH` statements) for multi-step aggregation
- Conditional aggregation using `CASE WHEN` inside `COUNT` and `MAX`
- `NULLIF` to safely handle divide-by-zero
- `HAVING` to filter aggregated results
- Integer division fix — using `* 100.0` before dividing to force decimal precision
- `GROUP BY` with `match_id + striker` to correctly calculate per-match scores before rolling up

---

# Thought Process & Edge Cases Solved

# Balls Faced — Not as simple as COUNT(*), Cricket has three delivery types that affect counting differently:

| Delivery | Count as ball faced? | Count runs_of_bat? |
|---|---|---|
| Normal | ✅ | ✅ |
| No-ball | ❌ | ✅ (batsman still scored) |
| Wide | ❌ | ❌ |
| Leg bye / Bye | ✅  ✅ (runs_of_bat = 0) |

This means you can't use `COUNT(*)` or filter `WHERE extras = 0`. The correct approach:
```sql
COUNT(CASE WHEN wide = 0 AND noballs = 0 THEN 1 END) AS balls_faced
```

# Strike Rate — Integer Division Bug

`SUM(runs) * 100 / SUM(balls)` gives wrong results in SQL because integer division truncates decimals before multiplying. Fix:
```sql
ROUND(SUM(run_per_match) * 100.0 / NULLIF(SUM(ball_inmatch), 0), 2)
```

# Highest Score — Needs match_id in CTE

Without `match_id` in the CTE group by, `MAX(run_per_match)` would just return total runs (same as `SUM`). Grouping by `match_id, striker` first gives true per-match scores.

# Batting Average

A batsman is out only when `player_dismissed = striker`. Used `MAX(CASE WHEN ...)` per match to flag dismissals, then divided total runs by total dismissals.

---

# Key Findings

# Top Batsmen — Total Runs > 300 (A good total score), Average > 30 (above 30 is good average in T20 match), Strike Rate > 130 (Tough it varies like if average is above 30-35 stike rate
above 130 is good, but for lower order finisher above 150 strike rate is good with low average but here we considering overall top batsman)

| Player | Total Runs | Highest Score | Strike Rate | Average |
|---|---|---|---|---|
| Sai Sudharsan | 759 | 108 | 156.17 | 54.21 |
| Suryakumar Yadav | 717 | 73 | 167.92 | 65.18 |
| Kohli | 657 | 73 | 144.71 | 54.75 |
| Shubman Gill | 650 | 93 | 157.00 | 54.17 |
| Mitchell Marsh | 627 | 117 | 164.57 | 48.23 |
| Shreyas Iyer | 604 | 97 | 176.09 | 50.33 |
| Prabhsimran | 599 | 91 | 162.77 | 35.24 |
| Jaiswal | 559 | 75 | 159.71 | 43.00 |
| Rahul | 546 | 112 | 150.41 | 60.67 |
| Priyansh Arya | 545 | 103 | 182.89 | 30.28 |
| Abhishek Sharma | 439 | 141 | 195.11 | 36.58 |
| Pooran | 524 | 87 | 197.74 | 47.64 |

> Notable: Sai Sudharsan topped the run charts. Pooran had the highest strike rate (197.74) among consistent performers. Abhishek Sharma's highest score of 141 was the biggest individual innings in this filtered list.

---

# How to Run

# MySQL / PostgreSQL
```sql
CREATE TABLE ipl_2025_deliveries (...); -- see schema/create_table.sql
LOAD DATA INFILE 'ipl_2025_deliveries.csv' INTO TABLE ipl_2025_deliveries;
```
