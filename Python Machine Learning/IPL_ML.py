import mysql.connector
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

from sqlalchemy import create_engine

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report, roc_auc_score


engine = create_engine(
    "mysql+mysqlconnector://root:MyNewPassword123@localhost/ipl"
)


deliveries = pd.read_sql("select * from deliveries;", engine)
matches = pd.read_sql("select * from temp;", engine)


bins = [0, 6, 15, 20]
labels = ['powerplay', 'mid_over', 'death_over']

deliveries['over_phase'] = pd.cut(
    deliveries['over_number'],
    bins=bins,
    labels=labels,
    include_lowest=True
)

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
deliveries['run_rate'] = deliveries['runs_scored'] / deliveries['overs_played']


total_balls = 120

deliveries['balls_remaining'] = total_balls - deliveries['ball_number']
deliveries['overs_remaining'] = deliveries['balls_remaining'] / 6

deliveries['runs_remaining'] = (
    deliveries['target_runs'] - deliveries['runs_scored']
)

deliveries['required_run_rate'] = (
    deliveries['runs_remaining'] / deliveries['overs_remaining']
)

deliveries['required_run_rate'] = deliveries['required_run_rate'].replace(
    [np.inf, -np.inf],
    np.nan
)

deliveries.loc[
    deliveries['inning'] == 1,
    'required_run_rate'
] = np.nan

deliveries['pressure_index'] = (
    deliveries['required_run_rate'] - deliveries['run_rate']
)


deliveries['pressure_level'] = np.select(
    condlist=[
        deliveries['pressure_index'] <= 0,
        (deliveries['pressure_index'] > 0) & (deliveries['pressure_index'] <= 2),
        deliveries['pressure_index'] > 2
    ],
    choicelist=[
        'low_pressure',
        'medium_pressure',
        'high_pressure'
    ],
    default='unknown'
)

                        #   ML MODEL
ml_df = deliveries[deliveries['inning'] == 2].copy()

ml_df = ml_df.dropna(subset=[
    'runs_remaining',
    'balls_remaining',
    'run_rate',
    'required_run_rate',
    'pressure_index'
])

ml_df['wickets_lost'] = ml_df.groupby(
    ['match_id', 'inning']
)['is_wicket'].cumsum()

ml_df['wickets_remaining'] = 10 - ml_df['wickets_lost']

ml_df['win'] = np.where(
    ml_df['batting_team'] == ml_df['winner'],
    1,
    0
)


features = [
    'runs_remaining',
    'balls_remaining',
    'run_rate',
    'required_run_rate',
    'pressure_index',
    'wickets_remaining'
]

x = ml_df[features]
y = ml_df['win']


x_train, x_test, y_train, y_test = train_test_split(
    x,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

model = LogisticRegression(max_iter=1000)
model.fit(x_train, y_train)

y_pred = model.predict(x_test)
y_prob = model.predict_proba(x_test)[:, 1]

print("accuracy:", accuracy_score(y_test, y_pred))
print("roc_auc:", roc_auc_score(y_test, y_prob))
print(classification_report(y_test, y_pred))

plot_df = x_test.copy()
plot_df['win_probability'] = y_prob
plot_df = plot_df.sort_values('balls_remaining')

plt.figure(figsize=(10,5))
plt.plot(plot_df['balls_remaining'], plot_df['win_probability'])
plt.xlabel('balls remaining')
plt.ylabel('win probability')
plt.title('win probability vs balls remaining')
plt.tight_layout()
plt.show()
