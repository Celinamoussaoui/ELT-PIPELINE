# 📊 ELT Pipeline Marketing

Ce projet met en œuvre un pipeline **ELT complet** pour centraliser, transformer et analyser des données marketing issues de **Google Ads, Facebook Ads, Emailing et CRM**.

Il s'agit d'une mise en situation réaliste simulée localement, avec des fichiers CSV structurés comme des exports réels d'outils marketing.

---

## 🧱 Stack technique utilisée

- **Airflow** : orchestration du pipeline (extraction et chargement)
- **Google Cloud Storage (GCS)** : stockage intermédiaire des fichiers CSV
- **BigQuery** : entrepôt de données
- **dbt** : transformation des données (modèles staging, intermédiaires et mart)
- **Looker Studio** : visualisation des performances marketing

---

## ⚙️ Fonctionnement du pipeline

1. 📥 **Extraction & Chargement**
   - Chargement de fichiers simulant les exports de campagnes **Google Ads**, **Facebook Ads**, **Email**, et **leads CRM**
   - Upload vers GCS, puis import automatisé dans BigQuery via Airflow

2. 🧽 **Transformation avec dbt**
   - Nettoyage et typage des données (`stg_*`)
   - Agrégation par canal (`int_*`)
   - Fusion multi-source dans une table `mart_campaign_performance` prête pour l’analyse

3. 📊 **Dashboard (Google Ads finalisé)**
   - KPI globaux (CPC, CPA, ROAS…)
   - Analyse par campagne
   - Problématiques métiers et insights intégrés

---

## 🖥️ Dashboard

📍 Dashboard Google Ads (interactif) :  
👉 [Voir dans Looker Studio](https://lookerstudio.google.com/reporting/ccd7ee89-f670-4fb7-ba6d-96637661b92b)

