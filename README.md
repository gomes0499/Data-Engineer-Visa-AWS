# Data-Engineer - Visa - Study Case

## Visa

The problem domain involves ingesting, processing, and analyzing transactional data in real time to identify suspicious patterns or anomalies. The project aims to minimize the financial impact of fraud on Visa's customers and merchants while maintaining a seamless user experience. Stakeholders include Visa management, fraud prevention teams, and financial institutions that rely on Visa's payment network for secure transactions.

### Data Pipeline Steps

1. **Infrastructure**: Provision necessary GCP resources using Terraform.
2. **CI/CD**: GitHub Actions as a CI/CD platform for the Terraform infrastructure.
3. **Data Modeling**: Python script using the Faker library to simulate transaction data with details such as transaction_id, card_number, card_holder, amount, currency, merchant, and timestamp.
4. **Data Ingestion**: Ingest the generated data into the AWS ecosystem using Kinesis Data Stream for real-time event streaming.
5. **Data Lake Raw Storage**: Use Kinesis Firehose to send the streaming data to the raw zone of an S3-based data lake.
6. **Data Processing**: AWS Glue to extract the data from the raw zone, apply necessary processing, and transform the data into Parquet format, stored in the processed zone of the data lake.
7. **Data Warehouse**: Load the processed data into Amazon Redshift for storage and analysis.
8. **Data Transformation**: DBT to transform and clean the data in Redshift, making it suitable for reporting and analytics purposes.
9. **Data Orchestration**:  Set up a dag for Apache Airflow environment.
10. **Data Analysis**: Jupyter Notebook to perform data analysis and develop a machine learning model to detect potential fraudulent transactions.

### Pipeline Diagram

![alt text](https://github.com/gomes0499/Data-Engineer-Visa-AWS/blob/main/Visa.png)

### Tools

* Python
* Terraform
* Github Actions
* AWS Kinesis Data Stream
* AWS Kinesis Firehose
* AWS S3
* AWS Glue
* Amazon Redshift
* DBT
* Airflow
* Jupyter Notebook

### Note

This repository is provided for study purposes only, focusing on data engineering pipelines.

## License

[MIT](https://choosealicense.com/licenses/mit/)
