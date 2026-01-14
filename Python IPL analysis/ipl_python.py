import mysql.connector
import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sqlalchemy import create_engine

conn=mysql.connector.connect(
    host="localhost",
    user="root",
    password="Your_Password",
    database="ipl",
    auth_plugin="mysql_native_password"
)


# Format: mysql+mysqlconnector://user:password@host/database
engine = create_engine("mysql+mysqlconnector://root:MyNewPassword123@localhost/ipl")



deliveries=pd.read_sql("select * from deliveries;",engine)
matches=pd.read_sql("select * from temp",engine)


def fetch_data(query):
    return pd.read_sql(query, engine)

def plot_bar(x, y,title, xlabel, ylabel, color):
    plt.figure(figsize=(8, 5))
    plt.bar(x, y, color = color)
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.xticks(rotation=45)
    plt.tight_layout()
    


bins=[0,6,15,20]
labels=['powerplay','mid_over','death_over']
deliveries['over_phase']= pd.cut(deliveries['over_number'],bins=bins,labels=labels, include_lowest=True)


deliveries['ball_outcome'] = np.select(
    condlist=[
        deliveries['is_wicket'] == 1,
        deliveries['batsman_runs'] == 6,
        deliveries['batsman_runs'] == 4,
        deliveries['total_runs'] == 0,
        deliveries['extra_runs'] > 0
    ],
    choicelist=[
        'wicket',
        'six',
        'four',
        'dot_ball',
        'extra'
    ],
    default='normal_run'
)


deliveries = deliveries.merge(
    matches,
    left_on='match_id',
    right_on='id',
    how='left'
)

deliveries = deliveries.sort_values(
    ['match_id', 'inning', 'over_number', 'ball']
)
deliveries['ball_number'] = (
    deliveries.groupby(['match_id', 'inning']).cumcount() + 1
)
deliveries['runs_scored'] = (
    deliveries.groupby(['match_id', 'inning'])['total_runs'].cumsum()
)
deliveries['overs_played'] = deliveries['ball_number'] / 6

deliveries['run_rate'] = (
    deliveries['runs_scored'] / deliveries['overs_played']
)
TOTAL_BALLS = 120

deliveries['balls_remaining'] = TOTAL_BALLS - deliveries['ball_number']
deliveries['overs_remaining'] = deliveries['balls_remaining'] / 6

deliveries['runs_remaining'] = (
    deliveries['target_runs'] - deliveries['runs_scored']
)

deliveries['required_run_rate'] = (
    deliveries['runs_remaining'] / deliveries['overs_remaining']
)
deliveries['required_run_rate'] = deliveries['required_run_rate'].replace(
    [np.inf, -np.inf], np.nan
)

deliveries.loc[deliveries['inning'] == 1, 'required_run_rate'] = np.nan



deliveries['pressure_index'] = (
    deliveries['required_run_rate'] - deliveries['run_rate']
)

deliveries['pressure_level'] = np.select(
condlist = [
    deliveries['pressure_index'] <= 0,
    (deliveries['pressure_index'] > 0) & (deliveries['pressure_index'] <= 2),
    deliveries['pressure_index'] > 2
],

choicelist = ['Low Pressure', 'Medium Pressure', 'High Pressure'],
default='Unknown'
)

# Total matches per season 
query1= ''' select season , count(*) as match_count
 from temp 
 group by season
 order by match_count desc;'''

df1=fetch_data(query1)
plot_bar(df1['season'],df1['match_count'],'Total Matches Per Season', 'Seasons', 'Total Matches','orange')
plt.savefig('Seasonwise_matchcount.png',bbox_inches='tight')
plt.show()
# total wins
query2='''select  winner, count(winner) as total_wins
-- rank() over( partition by season order by count(winner) desc) as ranking
from temp 
group by winner
order by total_wins desc;
'''

df2=fetch_data(query2)

y= np.arange(len(df2))

plt.figure(figsize=(10,5))
plt.bar(y,df2['total_wins'],color = 'lightgreen')
plt.title('total wins per team')
plt.xlabel('Team Names')
plt.ylabel('Total no.of wins')
plt.xticks(y,df2['winner'],rotation = 45, ha='right')
plt.tight_layout()
plt.savefig('Teams_with_wins.png', bbox_inches='tight')
plt.show()

query3 = '''select  season ,winner as team, count(*) as total_wins,
rank() over( partition by season order by count(winner) desc) as ranking
from temp 
group by winner, season
order by season, total_wins desc;
'''

# team wins per season 
df3= fetch_data(query3)

team = 'Mumbai Indians'

team_df = df3[df3['team'] == team]

plt.figure(figsize=(10,6))
plt.plot(team_df['season'], team_df['total_wins'], marker='o')
plt.xlabel('Season')
plt.ylabel('Wins')
plt.title(f'{team} Wins per Season')
plt.savefig('Team_wins_per_season.png',bbox_inches='tight')
plt.show()

#  toss winner win percentage

query4='''with win_loss as
(
SELECT 
    toss_winner AS team,
    COUNT(*) AS toss_wins,
    ROUND(
        (SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100, 
        2
    ) AS win_percent,
    ROUND(
        (SUM(CASE WHEN toss_winner <> winner THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100, 
        2
    ) AS loss_percent
FROM temp
GROUP BY toss_winner
ORDER BY win_percent DESC
)
select avg(win_percent) as win,
avg(loss_percent) as loss
from win_loss;'''

df4= fetch_data(query4)

plt.figure(figsize=(6,6))

plt.pie(
    df4.iloc[0].values,
    labels=df4.columns,
    startangle=90,
    autopct='%1.1f%%'
)

plt.title('Toss Decision Impact on Match Outcome')
plt.savefig('Toss_decision_impact.png',bbox_inches='tight')
plt.show()

query5 = '''select distinct season,toss_decision, count(toss_decision) as decision_count
from temp
group by toss_decision, season
order by season;'''

df5 = fetch_data(query5)

pivot_df = df5.pivot(
    index='season',
    columns='toss_decision',
    values='decision_count'
)

plt.figure(figsize=(12,6))

plt.bar(pivot_df.index, pivot_df['bat'], label='Bat',color = 'red')

plt.bar(pivot_df.index, pivot_df['field'], bottom=pivot_df['bat'], label='Field',color = 'blue')

plt.xlabel('Season')
plt.ylabel('Count')
plt.title('Season-wise Toss Decision Distribution')
plt.legend()
plt.savefig('Season_wise_toss_decision.png',bbox_inches='tight')
plt.show()

                                #    Ball by Ball Analysis plot
# top 10 runs scorers 

query6 = '''select batter, round(sum(batsman_runs),2) as total_runs
from deliveries
group by batter 
-- having total_runs >= 100
order by total_runs desc
limit 10;'''

df6 = fetch_data(query6)

plot_bar(df6['batter'],df6['total_runs'],'Top run scorers','batsman name','total runs', 'black')
plt.savefig('Top_batsmens.png',bbox_inches='tight')
plt.show()

# runs per over phase
query7 = '''with power_play as(
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
order by p.season;'''

df7 = fetch_data(query7)

x = np.arange(len(df7['season']))
width = 0.35

plt.figure(figsize=(12,6))

plt.bar(x - width/2, df7['pp_runs'], width, label='Powerplay Runs')
plt.bar(x + width/2, df7['do_runs'], width, label='Death Over Runs')

plt.xlabel('Season')
plt.ylabel('Total Runs')
plt.title('Season-wise Powerplay vs Death Over Runs')
plt.xticks(x, df7['season'], rotation=45)
plt.legend()
plt.savefig('powerplay_vs_deathovers.png',bbox_inches='tight')
plt.show()

# top wicket takers
query8 = '''select bowler, count(
case when is_wicket = 1 then 1 end
) as total_wickets
from deliveries 
group by bowler
order by total_wickets desc
limit 10;'''

df8 = fetch_data(query8)

plot_bar(df8['bowler'],df8['total_wickets'],'ranking of bowlers by wickets taken',
'bowler', 'total wickets','lightblue')
plt.savefig('Top_bowlers.png',bbox_inches='tight')
plt.show()


# Top player of the match winners
query9 = '''SELECT
    player_of_match,
    COUNT(*) AS pom_count
FROM temp
GROUP BY player_of_match
ORDER BY pom_count DESC
limit 5;'''

df9 =fetch_data(query9)

plot_bar(df9['player_of_match'],df9['pom_count'],'Players with most PoTM awards','Name','Total awards', 'red')
plt.savefig('Top player of the matches.png',bbox_inches='tight')
plt.show()

# Top venues based on total matches played 

query10 = '''select city, venue, count(match_type) as total_matches
from temp 
group by city, venue
order by total_matches desc 
limit 10;'''

df10 = fetch_data(query10)
z= np.arange(len(df10))
plt.figure(figsize=(10,5))
plt.bar(z,df10['total_matches'], color = 'yellow')
plt.title('Top Venues')
plt.xlabel('Venue')
plt.ylabel('Total Matches')
plt.xticks(z,df10['venue'],rotation=45, ha='right')
plt.tight_layout()
plt.savefig('Top_Venues.png',bbox_inches='tight')
plt.show()


# deliveries.to_csv('Feature_Engineered_IPL_Dataset')
# print('data saved successful')



