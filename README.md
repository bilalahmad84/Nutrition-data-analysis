 # 📊 Central Asia Stunting Initiative (CASI) — Data Analysis

> A comprehensive data cleaning and analysis project on child and maternal nutrition outcomes,
> conducted in collaboration with **Aga Khan University (AKU)**.

---

## 📋 Project Overview

This project involves end-to-end data cleaning and longitudinal analysis of nutrition data
collected under the **Central Asia Stunting Initiative (CASI)**. The workflow was built entirely
in **Stata** and covers data from districts of **Upper and Lower Chitral**, focusing on
monitoring stunting, malnutrition, and recovery outcomes in children under five.

---

## 🎯 Objectives

- Clean and standardize raw field-collected nutrition data
- Compute WHO anthropometric z-scores for child growth assessment
- Classify children by nutritional status (stunting, MAM, SAM, underweight)
- Track individual recovery and improvement over time
- Identify defaulters and loss to follow-up cases
- Generate district and village-level summaries for program monitoring

---

## 🛠️ Tools & Methods

| Tool | Purpose |
|------|---------|
| **Stata** | Data cleaning, analysis, z-score computation |
| **WHO `zscore06` Command** | Height-for-age, weight-for-age, weight-for-height z-scores |
| **Excel (.xlsx)** | Raw data source |

---

## 🔄 Workflow Summary

### 1. 📥 Data Import & Standardization
- Imported raw Excel datasets into Stata
- Renamed and standardized variable names for consistency

### 2. 🧹 Data Cleaning
- Removed duplicates based on unique child ID and assessment date
- Harmonized gender/sex variables
- Converted string anthropometric variables (height, weight, MUAC, BMI) to numeric
- Resolved inconsistent date formats for assessment dates and dates of birth
- Dropped irrelevant years and union councils

### 3. 📅 Age & Date Variables
- Calculated age in months and years from date of birth
- Created age group categories for children (0–5, 6–23, 24–59, 60+ months)
- Created age categories for women (15–24, 25–34, 35–44, 45–49)
- Generated monthly, quarterly, and yearly date variables

### 4. 📐 Anthropometric Z-Scores
- Computed **HAZ**, **WAZ**, **WHZ**, and **BMIZ** using WHO standards
- Flagged biologically implausible values for quality control

### 5. 🏷️ Nutritional Status Classification
- **Stunting & Growth Faltering** — based on HAZ scores
- **Underweight** — based on WAZ scores
- **MAM & SAM** — based on WHZ scores
- **Low Birth Weight (LBW)** — based on birth weight thresholds

### 6. 📈 Longitudinal Tracking
- Generated visit numbers and total visit counts per child
- Tracked transitions: Stunted → Normal, MAM → Normal, SAM → Normal
- Each recovery case uniquely counted per child

### 7. 🗺️ Geographic Analysis
- Summarized improved cases at **district** and **village** levels
- Cleaned village names for spatial consistency

### 8. 🚨 Program Monitoring
- Identified **loss to follow-up** cases (gap > 60 days between visits)
- Identified **defaulters** — children present in January 2024 but absent in June 2024

---

## 📁 Repository Structure
