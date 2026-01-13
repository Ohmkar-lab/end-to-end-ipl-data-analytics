                                   -- Data Analysis
                                   
                                   -- Tournament review 
-- Whats did the teams choose the most batting or bowling
select distinct toss_decision, count(toss_decision) as toss_decision
from temp
group by toss_decision;
-- As we can see feild is chose the most by the teams in overall seasons 

-- Which are the top successfull teams of all time? 
select winner, count(winner) as matches_won
from temp
group by winner
order by matches_won desc;
-- As we can see Mumbai Indians, Chennai Super Kings, Kolkata Knight Riders are the top most 
-- successful teams of all time 


-- Which are the cities where the most amount of matches were played?
select
    city,
    matches_played_in_city,
    rank() over (order by matches_played_in_city desc) as ranking
from (
    select
        city,
        count(city) as matches_played_in_city
    from temp
    group by city
) t;

-- As we can see Mumbai, Kolkata, Delhi are the top most cities where most amount of matches were played 

-- How many matches were played per season?

 select season , count(*) as match_count
 from temp 
 group by season
 order by match_count desc;
-- As we can see the amount of matches played in each season (Note- some seasons were played in span of 
-- 2 years like dec of first year and jean and feb of second year so its written in slash)

-- How has the number of teams changed over seasons?
with total_teams as(
select distinct season , team1 as team
from temp
union
select distinct season , team2 as team
from temp
)
select season, count(distinct team) as team_count
from total_teams
group by season
order by season;
-- As we can see different counts of teams per season having 10 number of teams the most and 10 number of teams in latest 2024 season

-- How many league vs playoff vs final matches are there?
select season, match_type, count(match_type) as counting
from temp 
group by season, match_type
order by season; 
-- These are the countings of league, playoff, final in every season 
-- 2013 and 2022 had most number of leagues (70) 

-- which season had the highest number of matches
select season, count(match_type) as total_matches
from temp
group by season
order by total_matches desc;
-- As we can see 2012, 2013, 2022 conducted the most number of matches including leagues, playoffs and finals 

-- Matches per city & venue
select city, venue, count(match_type) as total_matches
from temp 
group by city, venue
order by total_matches desc 
limit 10;
-- These are the matches that were conducted in these cities and venues 
                                          
                                          -- Team performance
                                          

-- These are the matches played by each team per season 
select 
    season,
    team,
    count(*) as matches_played
from (
    select season, team1 as team
    from temp
    
    union all
    
    select season, team2 as team
    from temp
) t
group by season, team
order by season, matches_played desc;

-- what is the total wins per team each season?
select  season ,winner team, count(*) as total_wins,
rank() over( partition by season order by count(winner) desc) as ranking
from temp 
group by winner, season
order by season, total_wins desc;
-- Here we can see total wins each team had in each season 

-- What are the win percentage per team
with team_wins as (
    select 
        season,
        winner as team,
        count(winner) as team_wins
    from temp
    group by season, winner
),
season_wins as (
    select 
        season,
        count(winner) as total_wins
    from temp
    group by season
)
select 
    tw.season,
    tw.team,
    tw.team_wins,
    sw.total_wins,
    round((tw.team_wins / sw.total_wins) * 100, 2) as win_percentage
from team_wins tw
join season_wins sw
    on tw.season = sw.season
order by tw.season, win_percentage desc;


                                      -- Toss analysis
with win_loss as
(
select 
    toss_winner as team,
    count(*) as toss_wins,
    round(
        (sum(case when toss_winner = winner then 1 else 0 end) * 1.0 / count(*)) * 100, 
        2
    ) as win_percent,
    round(
        (sum(case when toss_winner <> winner then 1 else 0 end) * 1.0 / count(*)) * 100, 
        2
    ) as loss_percent
from temp
group by toss_winner
order by win_percent desc
)
select avg(win_percent) as win,
avg(loss_percent) as loss
from win_loss;


-- Toss decision preference by season
select distinct season,toss_decision, count(toss_decision) as decision_count
from temp
group by toss_decision, season
order by season;
-- Here we can see different toss decision preferences per season 

-- Toss decision vs match result 
select toss_decision, count(winner) as total_winnings
from temp
group by toss_decision;

                                       -- Venue and Conditions
-- Which venue favour chasing?
select 
    venue,
    count(*) as matches_after_fielding,
    sum(case when toss_winner = winner then 1 else 0 end) as chasing_wins,
    round(
        (sum(case when toss_winner = winner then 1 else 0 end) * 1.0 / count(*)) * 100,
        2
    ) as chasing_win_percentage
from temp
where toss_decision = 'field'
group by venue
order by chasing_win_percentage desc;

-- These are the percentage for venues favouring chasing 

-- close matches per venue 
select 
    venue,
    count(*) as close_matches
from temp
where result = 'runs'
  and result_margin <= 5
group by venue
order by close_matches desc;

-- These are the amount of close matches occured on each venue 

-- Average winning margin per venue 
select venue, round(avg(result_margin),2) as avg_margin_runs,
count(*) as matches
from temp 
where result = 'runs'
group by venue
-- having matches >= 10 
-- use having if we need only stadiums with more than 10 matches played 
order by avg_margin_runs;
-- These are the average winning marigin per venue 

                                 -- Ball by Ball Analysis
                                 
							-- Batting analysis
-- Top scorer batsman overall 
select batter, round(sum(batsman_runs),2) as total_runs
from deliveries
group by batter 
-- having total_runs >= 100
order by total_runs desc
limit 10;
-- Here we can see top run scorers 

-- What is the strike rate of the batsmen 
with batting_stats as(
select batter , sum(batsman_runs) as total_runs,
count(
case when extras_type <> 'wides'
then 1
end
)as balls_faced
from deliveries 
group by batter
)
select batter, total_runs, balls_faced,
round((total_runs * 100.0 / balls_faced),2) as strike_rate
from batting_stats
having balls_faced> 100
order by strike_rate desc;



-- Boundary percentage (4s & 6s)
with boundaries as (
select 
count(
case when batsman_runs = 4
then 1 
end
) as total_fours,
count(
case when batsman_runs = 6
then 1 
end
) as total_sixes,
count(
case when batsman_runs in (4,6)
then 1 
end
) as total_boundaries
from deliveries
)
select round((total_fours * 100.0 / total_boundaries),2) as four_percentage,
round((total_sixes * 100.0 / total_boundaries),2) as six_percentage
from boundaries;

-- Around 69.58 percent are fours and 30.42 percent are sixes 

-- Runs per over (powerplay vs death overs)
with power_play as(
select m.season,
round(sum(d.total_runs),2) as pp_runs
from deliveries d
join temp m
on d.match_id=m.id
where over_number <=6
group by m.season
order by m.season
),
death_over as 
(
select m.season,
round(sum(d.total_runs),2) as do_runs
from deliveries d
join temp m
on d.match_id=m.id
where over_number >= 15
group by m.season
order by m.season
)
select p.season,p.pp_runs,d.do_runs
from power_play p
join death_over d
on p.season = d.season
group by p.season
order by p.season;
-- These are the runs per over for powerplay and death overs per season 
                              -- Bowling analysis
select d.bowler, m.season,
count(
case when d.is_wicket = 1 then 1 end
) as total_wickets
from deliveries d
join temp m
on d.match_id=m.id
group by bowler, season
order by season, total_wickets desc;

select bowler, count(
case when is_wicket = 1 then 1 end
) as total_wickets
from deliveries 
group by bowler
order by total_wickets desc
limit 10;
-- Here we can see total wickets of each bowler per season 

-- Economy rate of bowlers
create view legal_balls as
select bowler, count(bowler) as legals
from deliveries
where extras_type <> 'wides'
group by bowler;
select d.bowler, sum(d.total_runs) as runs_conceded, 
l.legals, round((sum(d.total_runs) * 6.0 / l.legals),2) as economy_rate
from deliveries d 
join legal_balls l
on d.bowler = l.bowler
group by d.bowler, l.legals
order by economy_rate;
-- These are the economy rates of every bowler in ipl

 -- Death over specialists
with death_overs_count as 
(
select m.season, d.bowler,
count(d.bowler) as death_overs_bowled
from deliveries d
join temp m 
on d.match_id = m.id
where d.over_number >=15
group by m.season,d.bowler
),
ranked_bowlers as 
(
select season, bowler, death_overs_bowled,
row_number() over(partition by season order by death_overs_bowled desc) as rn
from death_overs_count
)
select season, bowler, death_overs_bowled
from ranked_bowlers
where rn<=5
order by season, death_overs_bowled desc;
-- These are the death over specialists per season 

-- Dot ball percentage
select m.season,
count(d.total_runs) as count_total_runs,
count( case when d.total_runs = 0 then 1 end ) as count_dot_balls,
round(count( case when d.total_runs = 0 then 1 end ) * 100.0 / count(d.total_runs),2) as dot_ball_percentage
from deliveries d 
join temp m 
on d.match_id = m.id
group by m.season
order by m.season;
-- dot ball percentage per season

-- win probabilty per run bucket
with chase_progress as (
    select
        m.id as match_id,
        m.season,
        d.inning,
        d.batting_team,
        m.winner,
        d.over_number,

        -- runs scored till that over
        sum(d.total_runs) over (
            partition by d.match_id, d.inning
            order by d.over_number
            rows between unbounded preceding and current row
        ) as runs_scored,

        -- target
        m.target_runs

    from deliveries d
    join temp m
        on d.match_id = m.id
    where d.inning = 2
),

situations as (
    select
        match_id,
        season,
        batting_team,
        winner,

        -- key variables
        (target_runs - runs_scored) as runs_required,
        (20 - over_number) as overs_remaining,

        -- bucket runs required
        case
            when (target_runs - runs_scored) <= 20 then '0-20'
            when (target_runs - runs_scored) <= 40 then '21-40'
            when (target_runs - runs_scored) <= 60 then '41-60'
            when (target_runs - runs_scored) <= 80 then '61-80'
            else '80+'
        end as runs_bucket,

        -- bucket overs remaining
        case
            when (20 - over_number) <= 2 then '0-2'
            when (20 - over_number) <= 5 then '3-5'
            else '6+'
        end as overs_bucket,

        -- win flag
        case
            when batting_team = winner then 1
            else 0
        end as chase_win

    from chase_progress
    where (target_runs - runs_scored) > 0
)

select
    runs_bucket,
    overs_bucket,
    count(*) as total_cases,
    sum(chase_win) as wins,
    round((sum(chase_win) * 100.0 / count(*)), 2) as win_probability
from situations
group by runs_bucket, overs_bucket
order by overs_bucket, runs_bucket;


-- Target vs success rate
with chase_matches as (
    select
        id as match_id,
        season,
        target_runs,
        winner,
        team2 as chasing_team
    from temp
),

target_buckets as (
    select
        match_id,
        season,
        target_runs,

        case
            when target_runs <= 140 then '≤140'
            when target_runs <= 160 then '141–160'
            when target_runs <= 180 then '161–180'
            when target_runs <= 200 then '181–200'
            else '200+'
        end as target_range,

        case
            when winner = chasing_team then 1
            else 0
        end as chase_success
    from chase_matches
)

select
    target_range,
    count(*) as total_matches,
    sum(chase_success) as successful_chases,
    round((sum(chase_success) * 100.0 / count(*)), 2) as success_rate
from target_buckets
group by target_range
order by 
    min(target_runs);

    
-- powerplay runs and match result
with powerplay_runs as (
    select
        d.match_id,
        d.inning,
        d.batting_team,
        sum(d.total_runs) as pp_runs
    from deliveries d
    where d.over_number <= 6
    group by d.match_id, d.inning, d.batting_team
),

match_outcome as (
    select
        id as match_id,
        winner
    from temp
),

pp_with_result as (
    select
        p.match_id,
        p.batting_team,
        p.pp_runs,
        m.winner,
        case 
            when p.batting_team = m.winner then 1
            else 0
        end as is_win
    from powerplay_runs p
    join match_outcome m
        on p.match_id = m.match_id
)

select
    case
        when pp_runs <= 35 then '≤35'
        when pp_runs <= 45 then '36–45'
        when pp_runs <= 55 then '46–55'
        else '56+'
    end as powerplay_run_bucket,

    count(*) as total_innings,
    sum(is_win) as wins,
    round((sum(is_win) * 100.0 / count(*)), 2) as win_percentage
from pp_with_result
group by powerplay_run_bucket
order by min(pp_runs);


-- Player of the match distribution
select
    player_of_match,
    count(*) as pom_count
from temp
group by player_of_match
order by pom_count desc;


-- Players with most PoTM awards
select
    player_of_match,
    count(*) as pom_count
from temp
group by player_of_match
order by pom_count desc
limit 5;


select * from deliveries limit 10;
select * from temp limit 10;
 
 use ipl;