
select * from temp limit 10;
select * from deliveries limit 10;
set sql_safe_updates=0; 
--  Cleaning data
select distinct year (date) as match_year, count(*) as total_matches
from temp 
group by year (date)
order by match_year;


delete from temp
where id is null;


 select id, count(*)
from temp
group by id
having count(*) > 1;

set sql_safe_updates=0;
update temp
set city = 'Unknown'
where city is null;

update temp
set match_type = 'Unknown'
where match_type IS NULL;

select match_type, count(match_type) as count
from temp 
group by match_type;

select match_type, count(*)
from temp
where match_type in (
    'Semi Final',
    'Qualifier 1',
    'Qualifier 2',
    'Eliminator'
)
group by match_type;

update temp
set player_of_match = 'Unknown'
where player_of_match is null;

alter table temp
add column match_date date;

update temp
set match_date = str_to_date(date, '%Y-%m-%d');

alter table temp
drop column date;

alter table temp
rename column match_date to date;

select count(venue)
from temp 
where venue is null;

select count(team1)
from temp 
where team1 is null;

select count(team2)
from temp 
where team2 is null;

select team1, count(team1)
from temp 
group by team1;

update temp
set team1 = 'Delhi Capitals'
where team1 = 'Delhi Daredevils';

update temp
set team1 = 'Royal Challengers Bangalore'
where team1 = 'Royal Challengers Bengaluru';

update temp
set team1 = 'Punjab Kings'
where team1 = 'Kings XI Punjab';

update temp
set team1 = 'Rising Pune Supergiants'
where team1 = 'Rising Pune Supergiant';
update temp
set team1 = 'Rising Pune Supergiants'
where team1 = 'Pune Warriors';

update temp
set team1 = 'Gujarat Titans'
where team1 = 'Gujarat Lions';

-- team2
select team2, count(team2)
from temp 
group by team2;

update temp
set team2 = 'Delhi Capitals'
where team2 = 'Delhi Daredevils';

update temp
set team2 = 'Royal Challengers Bangalore'
where team2 = 'Royal Challengers Bengaluru';

update temp
set team2 = 'Punjab Kings'
where team2 = 'Kings XI Punjab';

update temp
set team2 = 'Rising Pune Supergiants'
where team2 = 'Rising Pune Supergiant';
update temp
set team2= 'Rising Pune Supergiants'
where team2 = 'Pune Warriors';

update temp
set team2 = 'Gujarat Titans'
where team2 = 'Gujarat Lions';

-- Winners

update temp
set winner = 'Delhi Capitals'
where winner = 'Delhi Daredevils';

update temp
set winner = 'Royal Challengers Bangalore'
where winner = 'Royal Challengers Bengaluru';

update temp
set winner = 'Punjab Kings'
where winner = 'Kings XI Punjab';

update temp
set winner = 'Rising Pune Supergiants'
where winner = 'Rising Pune Supergiant';
update temp
set winner= 'Rising Pune Supergiants'
where winner = 'Pune Warriors';

update temp
set winner = 'Gujarat Titans'
where winner = 'Gujarat Lions';

-- toss_winner
update temp
set toss_winner = 'Delhi Capitals'
where toss_winner = 'Delhi Daredevils';

update temp
set toss_winner = 'Royal Challengers Bangalore'
where toss_winner = 'Royal Challengers Bengaluru';

update temp
set toss_winner = 'Punjab Kings'
where toss_winner = 'Kings XI Punjab';

update temp
set toss_winner = 'Rising Pune Supergiants'
where toss_winner = 'Rising Pune Supergiant';
update temp
set toss_winner= 'Rising Pune Supergiants'
where toss_winner = 'Pune Warriors';

update temp
set toss_winner = 'Gujarat Titans'
where toss_winner = 'Gujarat Lions';

-- results

select count(result)
from temp 
where result is null;

select count(target_runs)
from temp 
where target_runs is null;

select count(target_overs)
from temp 
where target_overs is null;

select distinct method, count(*)
from temp
group by method;


update temp
set method = null
where trim(lower(method)) in ('na', 'n/a', '');

update temp
set method = 'No method'
where method is null;

select distinct super_over, count(*)
from temp
group by super_over;

select * from temp limit 10;

                   -- Now cleaning the data from deliveries dataset 

select * from deliveries 
limit 10;
          --   Match_id       
delete  
from deliveries
where match_id is null;
                --  inning
select distinct inning, count(*)
from deliveries 
group by inning;
select count(inning)
from deliveries 
where inning is null;

-- There is a bug in the dataset which shows that the matches dataset has no super over from 2008 to 2024 
-- and the deliveries dataset is contradicting this facor by showing there have been conducted 3rd and 4th innings 
-- which in itself is contradicting therefore this is a dataset bug which needs to be solved

             -- batting_team
             
update deliveries
set batting_team= 'Delhi Capitals'
where batting_team = 'Delhi Daredevils';

update deliveries
set batting_team = 'Royal Challengers Bangalore'
where batting_team = 'Royal Challengers Bengaluru';

update deliveries
set batting_team = 'Punjab Kings'
where batting_team = 'Kings XI Punjab';

update deliveries
set batting_team = 'Rising Pune Supergiants'
where batting_team = 'Rising Pune Supergiant';
update deliveries
set batting_team= 'Rising Pune Supergiants'
where batting_team = 'Pune Warriors';

update deliveries
set batting_team = 'Gujarat Titans'
where batting_team = 'Gujarat Lions';

                     -- bowling_team
                     
update deliveries
set bowling_team= 'Delhi Capitals'
where bowling_team = 'Delhi Daredevils';

update deliveries
set bowling_team = 'Royal Challengers Bangalore'
where bowling_team = 'Royal Challengers Bengaluru';

update deliveries
set bowling_team = 'Punjab Kings'
where bowling_team = 'Kings XI Punjab';

update deliveries
set bowling_team = 'Rising Pune Supergiants'
where bowling_team = 'Rising Pune Supergiant';
update deliveries
set bowling_team= 'Rising Pune Supergiants'
where bowling_team = 'Pune Warriors';

update deliveries
set bowling_team = 'Gujarat Titans'
where bowling_team = 'Gujarat Lions';
         
                      -- over_number
select count(over_number)
from deliveries
where over_number is null;
                         -- ball
select count(ball)
from deliveries
where ball is null;
                     
				        -- batter
select count(batter)
from deliveries
where batter is null;
update deliveries
set batter = trim(batter)
where batter is not null;
                       -- bowler

select count(bowler)
from deliveries
where bowler is null;
update deliveries
set bowler = trim(bowler)
where bowler is not null;

--                         non striker

select count(non_striker)
from deliveries
where non_striker is null;
update deliveries
set non_striker = trim(non_striker)
where non_striker is not null;


                        -- batsman_runs
                        

select count(batsman_runs)
from deliveries
where batsman_runs is null;

select count(batsman_runs)
from deliveries 
where batsman_runs > 6;

                           -- extra_types
                           
update deliveries
set extras_type = 'no extras'
where extras_type is null;   

                         -- player dismissed   
update deliveries
set player_dismissed = 'no'
where player_dismissed is null;                         
                       -- dismissal kind  
select dismissal_kind,count(dismissal_kind)
from deliveries
group by dismissal_kind;

update deliveries
set dismissal_kind = 'unknown'
where dismissal_kind is null;
select * from deliveries limit 20;
                             -- feilder
update deliveries
set fielder = 'N'
where fielder is null;
                           -- extra runs
                           
select count(extra_runs)
from deliveries
where extra_runs is null;
                            -- total_runs

select count(total_runs)
from deliveries
where total_runs is null;  

                           -- is_wicket
select count(is_wicket)
from deliveries
where is_wicket is null;


start transaction;
update temp
set city = 'Bangalore'
where city = 'Bengaluru';

update temp
set city = null
where trim(lower(city)) in ('na', 'n/a', '');

update temp
set city = 'Dubai'
where venue = 'Dubai International Cricket Stadium';

update temp
set city = 'Sharjah'
where venue = 'Sharjah Cricket Stadium';

update temp 
set venue = 'Sheikh Zayed Stadium'
where venue = 'Zayed Cricket Stadium, Abu Dhabi';

update temp
set venue = 'M.Chinnaswamy Stadium'
where venue in ('M Chinnaswamy Stadium, Bengaluru','M Chinnaswamy Stadium');

update temp
set venue = 'Punjab Cricket Association IS Bindra Stadium'
where venue in ('Punjab Cricket Association IS Bindra Stadium, Mohali',
'Punjab Cricket Association IS Bindra Stadium, Mohali, Chandigarh',
'Punjab Cricket Association IS Bindra Stadium, Mohali',
'Punjab Cricket Association Stadium, Mohali');

update temp
set venue = 'MA Chidambaram Stadium'
where venue in ('MA Chidambaram Stadium, Chepauk, Chennai',
'MA Chidambaram Stadium, Chepauk');

update temp
set venue = 'Dr DY Patil Sports Academy'
where venue = 'Dr DY Patil Sports Academy, Mumbai';
update temp
set city = 'Navi Mumbai'
where venue = 'Dr DY Patil Sports Academy';

update temp
set venue = 'Arun Jaitley Stadium'
where venue = 'Arun Jaitley Stadium, Delhi';

update temp
set venue = 'Himachal Pradesh Cricket Association Stadium'
where venue = 'Himachal Pradesh Cricket Association Stadium, Dharamsala';

update temp
set venue = 'Rajiv Gandhi International Stadium'
where venue in ('Rajiv Gandhi International Stadium, Uppal',
'Rajiv Gandhi International Stadium, Uppal, Hyderabad');

update temp
set venue = 'Sawai Mansingh Stadium'
where venue = 'Sawai Mansingh Stadium, Jaipur';

update temp
set venue = 'Eden Gardens'
where venue = 'Eden Gardens, Kolkata';

update temp
set venue = 'Brabourne Stadium'
where venue = 'Brabourne Stadium, Mumbai';

update temp
set venue = 'Wankhede Stadium'
where venue = 'Wankhede Stadium, Mumbai';

update temp
set venue = 'Maharashtra Cricket Association Stadium'
where venue = 'Maharashtra Cricket Association Stadium, Pune';

update temp
set venue = 'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium'
where venue = 'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium, Visakhapatnam';

commit;

set sql_safe_updates = 0;
-- Data cleaing of both the datasets is completed with removing null values and chaning the format to standard format which
-- which is easy to do operations on and is same throughout the dataset 