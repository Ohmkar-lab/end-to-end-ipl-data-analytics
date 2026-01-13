create database if not exists ipl;
use ipl;

create table temp(
id	int primary key,
season	varchar(100),
city	varchar(100),
date	date,
match_type	varchar(100),
player_of_match	varchar (100),
venue	varchar(100),
team1	varchar(100),
team2	varchar(100),
toss_winner	varchar (100),
toss_decision	varchar (100),
winner	varchar (100),
result	varchar (100),
result_margin	int,
target_runs	int,
target_overs	int,
super_over	varchar (100),
method	varchar (100),
umpire1	varchar (100),
umpire2 varchar (100)
);
-- Imported the data in temp with import wizard 

select count(id) from temp
where id is null;

create table deliveries (
    match_id int not null,
    inning tinyint not null,
    batting_team varchar(100) not null,
    bowling_team varchar(100) not null,
    over_number tinyint not null,
    ball tinyint not null,
    batter varchar(100) not null,
    bowler varchar(100) not null,
    non_striker varchar(100),
    batsman_runs tinyint default 0,
    extra_runs tinyint default 0,
    total_runs tinyint default 0,
    extras_type varchar(50),
    is_wicket tinyint default 0,
    player_dismissed varchar(100),
    dismissal_kind varchar(50),
    fielder varchar(100),

    primary key (match_id, inning, over_number, ball)
);


-- Had to import data through python as dataset is big

set global local_infile = 1;
