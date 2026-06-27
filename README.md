# SkyFlow: End-to-End Aviation Business Intelligence & NLP Analytics Platform

An enterprise-grade, cross-platform business intelligence application that unifies massive real-world operational airline tracking with machine learning-driven text mining. This project bridges data warehousing, natural language processing (NLP), and multi-platform dashboard deployment (Power BI & Tableau) to expose operational bottlenecks and optimize customer experience strategies.

---

## 🌐 Live Production Dashboards
* 📊 **Strategic Executive Dashboard:** [View Live Tableau Dashboard Platform](https://public.tableau.com/app/profile/anurag.srivastva/viz/SkyFlowCXStrategyHub/SkyFlowCXStrategyHub?publish=yes)
* 📋 **Operational Control Room:** Configured via `SkyFlow_Operations.pbit` (Template source included in repository assets).

---

## 💾 Source Datasets & Attribution
To mirror an authentic corporate enterprise scenario, this system integrates two distinct massive data layers:

1.  **US Department of Transportation (DOT) Flight Delays:** Utilizes the core `flights.csv` master file containing millions of real-world domestic flight tracking vectors, carrier metrics, and regional delay tracking parameters. 
    * *Source:* [Kaggle / US DOT Flight Delays Archive](https://www.kaggle.com/datasets/usdot/flight-delays)
2.  **Airline Passenger Satisfaction Surveys:** Utilizes the raw customer feedback matrices and qualitative flight experience evaluation responses to serve as our target NLP text mining engine corpus.
    * *Source:* [Kaggle / Airline Passenger Satisfaction Data](https://www.kaggle.com/datasets/teejmahal20/airline-passenger-satisfaction)

---

## 🛠 Tech Stack & Architecture
               [Raw Flight Operations Data]      [Raw Text Reviews]
                    (flights.csv)           (Passenger Satisfaction)
                         │                              │
                         ▼                              ▼
                [MS SQL Server DW]             [Google Colab (Python)]
              (T-SQL Ingestion & ETL)         (VADER NLP Sentiment Engine)
                         │                              │
                         ▼                              ▼
             [Power BI Control Room]        [Tableau Strategic Suite]
            (DAX / AI Key Influencers)     (4-Quadrant Experience Hub)

---
* **Database:** Microsoft SQL Server (T-SQL, Star-Schema Modeling, Index Optimization, Bulk Insertion)
* **Data Science / NLP:** Python 3 (Pandas, NLTK VADER Lexicon Engine) via Google Colab
* **Operational Reporting:** Power BI Desktop (Advanced DAX, Smart Narrative NLP, Machine Learning Key Influencers)
* **Executive Strategy UI:** Tableau Desktop / Tableau Public (Multi-dimensional Heatmaps, Scatter Distribution, Interactive Filtering)

---

## 📂 Project Structure & Components

### 1. Data Warehousing (MS SQL Server)
The operational backbone uses an optimized star-schema design configured in MS SQL Server to handle multi-million row airline performance records seamlessly from the DOT `flights.csv` dataset.

* **ETL Execution:** Implemented high-efficiency `BULK INSERT` T-SQL scripts to rapidly map flat files into structured staging environments.
* **Optimization:** Configured clustered indexes on surrogate primary keys (`Flight_Key`, `Review_Key`) and non-clustered indexes on high-frequency filtering dimensions (`Airline_Code`, `Origin_Airport`) to achieve sub-second query execution times.

### 2. Natural Language Processing (Google Colab Workspace)
To capture passenger sentiment beneath binary satisfaction markers from the Passenger Satisfaction dataset, a Python NLP pipeline was built to clean, process, and analyze raw customer review text.

```python
import pandas as pd
from nltk.sentiment.vader import SentimentIntensityAnalyzer

# Initialize VADER Lexicon Engine
sia = SentimentIntensityAnalyzer()

# Apply sentiment text-mining engine
df['Sentiment_Score'] = df['Review_Text'].apply(lambda text: sia.polarity_scores(str(text))['compound'])
df['Sentiment_Category'] = df['Sentiment_Score'].apply(lambda score: 'Positive' if score > 0.05 else ('Negative' if score < -0.05 else 'Neutral'))
```
### 3. Operational Control Room (Power BI)
A two-page diagnostic suite engineered to automate real-time scheduling assessments and track systemic infrastructure pressures.

**Page 1:** Executive Control Summary: Features custom, non-linear DAX measures feeding a dynamic Smart Narrative AI Box that rewrites its analytical executive briefings automatically as users apply dashboard filters.

**Page 2:** Delay Analytics Hub: Utilizes an integrated machine learning Key Influencers visual to perform automated linear regressions, mathematically isolating exactly which internal operational variables correlate to severe flight overruns.

---
### 4. Strategic Customer Experience Hub (Tableau)
An executive boardroom application engineered to visually isolate the breaking point where terminal scheduling overruns destroy passenger brand loyalty.

* **Sentiment Heatmap:** Cross-tabulates `Class` and `Type of Travel` against customer satisfaction scores, applying a Red-Green diverging matrix to immediately expose low-performing demographic clusters.
* **Delay Friction Matrix:** An alpha-blended scatter plot built at a 50% circle opacity level to expose the high-density distribution boundaries where operational arrival times drag NLP-derived text sentiments into toxic thresholds.
* **Service Quality Matrix (Strategic Gap Analysis):** Benchmarks key operational touchpoints (such as Flight Distance, Arrival Delays, and Departure Delays) across different sentiment classes using a customized horizontal bar chart to identify core operational failure points.
* **Review Text Miner:** An interactive visual terminal binding raw text blocks to machine learning categorization markers, enabling granular review drills driven by global dashboard slicing parameters.

---
### 📈 Impact & Business Value
**Automation:** Eliminated manual data compilation cycles by serving automated executive textual summaries natively inside dashboards.

**Root-Cause Extraction:** Shifted operations from reactive reporting to predictive monitoring by identifying the explicit financial risks associated with cascading late aircraft variables.

**Unified Feedback Loop:** Linked back-end database metrics with front-end qualitative consumer voices to empower data-driven scheduling changes.
