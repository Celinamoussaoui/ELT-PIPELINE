from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from airflow.providers.google.cloud.transfers.local_to_gcs import LocalFilesystemToGCSOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 0,
    'retry_delay': timedelta(minutes=5),
}

GCS_BUCKET = "bucket_original"
BQ_DATASET = "marketing"
FILES = ["google_ads_campaigns.csv", "facebook_ads_campaigns.csv", "email_campaigns.csv", "crm_leads.csv"]

@dag(
    default_args=default_args,
    schedule=None,
    catchup=False,
    render_template_as_native_obj=True
)
def elt_pipeline():

    upload_tasks = {}
    load_tasks = {}

    for file in FILES:
        table_name = file.replace('.csv', '')
        full_table_id = f"{BQ_DATASET}.raw_{table_name}"

        upload_tasks[table_name] = LocalFilesystemToGCSOperator(
            task_id=f"upload_{table_name}",
            src=f"/opt/airflow/dags/data/{file}",
            dst=f"raw/{file}",
            bucket=GCS_BUCKET,
            gcp_conn_id="google_cloud_default",
            mime_type="text/csv"
        )

        load_tasks[table_name] = GCSToBigQueryOperator(
            task_id=f"load_{table_name}_to_bq",
            bucket=GCS_BUCKET,
            source_objects=[f"raw/{file}"],
            destination_project_dataset_table=full_table_id,
            skip_leading_rows=1,
            source_format="CSV",
            create_disposition="CREATE_IF_NEEDED",
            write_disposition="WRITE_TRUNCATE",
            gcp_conn_id="google_cloud_default",
        )

        upload_tasks[table_name] >> load_tasks[table_name]

    # STAGING
    run_google_staging = BashOperator(
        task_id="run_google_staging",
        bash_command="docker exec dbt dbt run --select path:models/staging/stg_google_ads_campaigns.sql"
    )

    run_facebook_staging = BashOperator(
        task_id="run_facebook_staging",
        bash_command="docker exec dbt dbt run --select path:models/staging/stg_facebook_ads_campaigns.sql"
    )

    run_email_staging = BashOperator(
        task_id="run_email_staging",
        bash_command="docker exec dbt dbt run --select path:models/staging/stg_email_campaigns.sql"
    )

    run_crm_staging = BashOperator(
        task_id="run_crm_staging",
        bash_command="docker exec dbt dbt run --select path:models/staging/stg_crm_leads.sql"
    )

    # INTERMEDIATE (run tous les modèles intermédiaires)
    run_int_google_daily = BashOperator(
        task_id="run_int_google_daily",
        bash_command="docker exec dbt dbt run --select path:models/intermediate/int_google_campaign_daily.sql"
    )

    run_int_google_summary = BashOperator(
        task_id="run_int_google_summary",
        bash_command="docker exec dbt dbt run --select path:models/intermediate/int_google_campaign_summary.sql"
    )

    run_int_google_keywords = BashOperator(
        task_id="run_int_google_keywords",
        bash_command="docker exec dbt dbt run --select path:models/intermediate/int_google_keywords.sql"
    )
        # INTERMEDIATE - Facebook
    run_int_facebook = BashOperator(
        task_id="run_int_facebook",
        bash_command="docker exec dbt dbt run --select path:models/intermediate/int_facebook_campaign_performance.sql"
    )

    # INTERMEDIATE - Email
    run_int_email = BashOperator(
        task_id="run_int_email",
        bash_command="docker exec dbt dbt run --select path:models/intermediate/int_email_campaign_performance.sql"
    )

    # MART (run la table finale)
    run_mart = BashOperator(
        task_id="run_mart_model",
        bash_command="docker exec dbt dbt run --select path:models/mart"
    )

    # Dépendances : charger les fichiers >> staging
    load_tasks["google_ads_campaigns"] >> run_google_staging
    load_tasks["facebook_ads_campaigns"] >> run_facebook_staging
    load_tasks["email_campaigns"] >> run_email_staging
    load_tasks["crm_leads"] >> run_crm_staging

    # Dépendances : STAGING >> INTERMEDIATE
    [run_google_staging, run_crm_staging] >> run_int_google_daily
    run_int_google_daily >> run_int_google_summary
    run_int_google_summary >> run_int_google_keywords

    run_facebook_staging >> run_int_facebook
    run_email_staging >> run_int_email

    # Dépendances : INTERMEDIATE >> MART
    [run_int_google_summary, run_int_facebook, run_int_email] >> run_mart


dag = elt_pipeline() 
