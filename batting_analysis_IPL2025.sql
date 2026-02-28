USE sample;
-- ================================================
-- TOP BATTING PERFORMANCE - IPL 2025
-- Filters: Total Runs > 300, Average > 30, Strike Rate > 130
-- ================================================
-- Note: Balls faced excludes wides and no-balls (cricket official rule)
-- No-ball runs still counted in total runs (runs_of_bat captured separately)
-- Average calculated only when player is dismissed (player_dismissed = striker)

WITH table1 AS (
    SELECT 
        striker, 
        match_id, 
        SUM(runs_of_bat) AS run_per_match,
        COUNT(CASE WHEN wide = 0 AND noballs = 0 THEN 1 END) AS ball_inmatch,
        MAX(CASE WHEN player_dismissed = striker THEN 1 ELSE 0 END) AS player_out
    FROM ipl_2025_deliveries
    GROUP BY striker, match_id
)
SELECT 
    striker,
    SUM(run_per_match) AS total_score,
    MAX(run_per_match) AS highest_score,
    ROUND(SUM(run_per_match) * 100.0 / NULLIF(SUM(ball_inmatch), 0), 2) AS strike_rate,
    CASE 
        WHEN SUM(player_out) = 0 THEN NULL 
        ELSE ROUND(SUM(run_per_match) * 1.0 / SUM(player_out), 2) 
    END AS average
FROM table1
GROUP BY striker
HAVING total_score > 300 AND average > 30 AND strike_rate > 130
ORDER BY total_score DESC;