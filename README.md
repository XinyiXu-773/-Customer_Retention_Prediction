# Customer Retention Prediction & Strategy (PlatefulNZ Case)

## Project Overview
This project aims to **predict customer churn (non-retention)** and translate model outputs into **actionable retention strategies**.  
Using customer behavioral, transactional, and satisfaction data, the analysis focuses on identifying **high-risk customers early** and supporting **targeted intervention decisions**.

The project is structured as a **reproducible analytics pipeline**, combining predictive modeling and customer segmentation to support data-driven retention planning.

---

## Data Description
- **Observations:** ~1,500 customers  
- **Features:** Demographics, purchase behavior, engagement metrics, satisfaction indicators  
- **Target Variable:**  
  - `retained` (binary)  
  - Defined as whether a customer remains active within a 90-day observation window  
  - Modeling focuses on identifying **churn (non-retention)** as the positive class

> Note: Raw data is not publicly shared. Processed data and variable definitions are documented for reproducibility.

---

## Methodology
The analysis follows a structured workflow:

1. **Data Cleaning & Feature Engineering**
   - Missing value handling
   - Factor encoding
   - Feature scaling for clustering

2. **Exploratory Data Analysis (EDA)**
   - Retention rate distribution
   - Key behavioral differences between retained and churned customers
   - Variable importance screening

3. **Predictive Modeling**
   - Logistic Regression (baseline & interpretable)
   - Random Forest (non-linear benchmark)
   - Cross-validation with consistent resampling
   - Evaluation metrics:
     - ROC-AUC
     - PR-AUC (for class imbalance)
     - Churn Recall & F1-score

4. **Threshold Optimization**
   - Classification threshold adjusted beyond the default 0.5
   - Optimized for **churn detection performance** under business constraints

5. **Customer Segmentation (Clustering)**
   - K-means clustering on behavioral features
   - Number of clusters selected using:
     - Elbow Method (WSS)
     - Silhouette Score
   - Clusters profiled and mapped to tailored retention actions

---

## Key Findings
- Customers with **higher purchase frequency** and **shorter inactivity periods** are significantly more likely to be retained
- Lower satisfaction scores are strongly associated with churn risk
- Random Forest slightly outperforms Logistic Regression in overall discrimination (AUC > 0.9)
- Adjusting the classification threshold improves **churn recall**, supporting proactive retention targeting
- Clustering reveals distinct customer segments with **different churn drivers**, enabling targeted interventions

---

## Business Recommendations
Based on model predictions and customer segments:

- **High-risk & inactive users:** Win-back campaigns with personalized incentives  
- **Low-satisfaction but active users:** Service recovery and experience improvements  
- **Price-sensitive segments:** Subscription optimization and targeted discounts  

These strategies aim to improve retention efficiency while controlling intervention costs.

---

## Project Structure
├── Analysis_Code.qmd        # Main Quarto analysis & report
├── code/                    # Modular R scripts
│   ├── 00_setup.R           # Package loading, seed setting
│   ├── 01_data_cleaning.R   # Data cleaning & feature engineering
│   ├── 02_eda.R             # Exploratory data analysis
│   ├── 03_modeling.R        # Predictive modeling & evaluation
│   └── 04_clustering.R      # Customer segmentation & profiling
├── data/                    # Data folder (raw data excluded)
├── docs/                    # Rendered HTML report (GitHub Pages)
│   └── index.html
├── outputs/                 # Figures and tables
├── README.md
└── LICENSE

---

## How to Reproduce
1. Clone this repository
2. Open the project in RStudio
3. Install required R packages (listed in the setup script)
4. Render the Quarto report:
   quarto render Analysis_Code.qmd
5. The rendered HTML report will be generated in the docs/ directory
