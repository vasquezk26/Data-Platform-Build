USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS governance_db;
CREATE SCHEMA IF NOT EXISTS governance_db.sch;


CREATE OR REPLACE SNOWFLAKE.DATA_PRIVACY.CLASSIFICATION_PROFILE
  governance_db.sch.my_classification_profile(
      {
        'minimum_object_age_for_classification_days': 0,
        'maximum_classification_validity_days': 30,
        'auto_tag': true
      });


CREATE TAG governance_db.sch.PII__RESTRICTED;
CREATE TAG governance_db.sch.PII__INTERNAL;
CREATE TAG governance_db.sch.HEALTH__RESTRICTED;
CREATE TAG governance_db.sch.HEALTH__INTERNAL;
CREATE TAG governance_db.sch.CLASS__RESTRICTED;
CREATE TAG governance_db.sch.CLASS__INTERNAL;

CALL governance_db.sch.my_classification_profile!SET_TAG_MAP(
  {'column_tag_map':[
    {
      'tag_name':'governance_db.sch.PII__RESTRICTED',
      'tag_value':'PII.Name',
      'semantic_categories':['NAME']
    },{
      'tag_name':'governance_db.sch.CLASS__RESTRICTED',
      'tag_value':'CLASS.Restricted',
      'semantic_categories':['NAME', 'PHONE_NUMBER', 'STREET_ADDRESS']
    },{
      'tag_name':'governance_db.sch.PII__INTERNAL',
      'tag_value':'PII.Gender',
      'semantic_categories':['GENDER']
    },{
      'tag_name':'governance_db.sch.CLASS__INTERNAL',
      'tag_value':'CLASS.Internal',
      'semantic_categories':['GENDER']
    }]});

ALTER SCHEMA raw.gcp_development_admin_backend_public
  SET CLASSIFICATION_PROFILE = 'governance_db.sch.my_classification_profile';


-- One Hour Later
CALL SYSTEM$GET_CLASSIFICATION_RESULT('raw.gcp_development_admin_backend_public.PATIENT');

-- run classification
-- CALL SYSTEM$CLASSIFY('HRZN_DB.HRZN_SCH.CUSTOMER', {'auto_tag': true});
CALL SYSTEM$CLASSIFY('raw.gcp_development_admin_backend_public.PATIENT', {'auto_tag': true});
-- CALL SYSTEM$CLASSIFY('HRZN_DB.HRZN_SCH.CUSTOMER',{'auto_tag': true, 'custom_classifiers': ['HRZN_DB.CLASSIFIERS.CREDITCARD']});
-- create or replace snowflake.data_privacy.custom_classifier CREDITCARD();

-- Show snowflake.data_privacy.custom_classifier;

-- --Add the regex for each credit card type that we want to be classified into
-- Call creditcard!add_regex('MC_PAYMENT_CARD','IDENTIFIER','^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$');
-- Call creditcard!add_regex('AMX_PAYMENT_CARD','IDENTIFIER','^3[4-7][0-9]{13}$')

SELECT TAG_DATABASE, TAG_SCHEMA, OBJECT_NAME, COLUMN_NAME, TAG_NAME, TAG_VALUE
FROM TABLE(
  GOVERNANCE_DB.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS(
    'RAW.gcp_development_admin_backend_public.PATIENT',
    'table'
));


ALTER TAG governance_db.sch.autodetect_pii SET
  MASKING POLICY raw.public.name_masking_policy;

-- doesn't work.
--  ALTER TAG governance_db.sch.autodetect_pii:['PII.Gender'] SET
--  MASKING POLICY raw.public.gender_masking_policy;

SELECT * FROM snowflake.account_usage.data_classification_latest;

ALTER TAG governance_db.sch.PII__RESTRICTED SET
  MASKING POLICY raw.public.pii_restricted_varchar_masking_policy
  , MASKING POLICY raw.public.pii_restricted_date_masking_policy;

ALTER TAG governance_db.sch.PII__INTERNAL SET
  MASKING POLICY raw.public.pii_internal_varchar_masking_policy
  , MASKING POLICY raw.public.pii_internal_date_masking_policy;

ALTER TAG governance_db.sch.HEALTH__RESTRICTED SET
  MASKING POLICY raw.public.health_restricted_varchar_masking_policy
  , MASKING POLICY raw.public.health_restricted_date_masking_policy;

ALTER TAG governance_db.sch.HEALTH__INTERNAL SET
  MASKING POLICY raw.public.health_internal_varchar_masking_policy
  , MASKING POLICY raw.public.health_internal_date_masking_policy
  , MASKING POLICY raw.public.health_internal_boolean_masking_policy;

ALTER TABLE RAW.GCP_DEVELOPMENT_ADMIN_BACKEND_PUBLIC.BIOMARKER_RESULT ALTER COLUMN COLLECTION_SITE SET TAG governance_db.sch.HEALTH__RESTRICTED = 'manual';
ALTER TABLE RAW.GCP_DEVELOPMENT_ADMIN_BACKEND_PUBLIC.BIOMARKER_RESULT ALTER COLUMN TEST_RESULT SET TAG governance_db.sch.HEALTH__RESTRICTED = 'manual';
ALTER TABLE RAW.GCP_DEVELOPMENT_ADMIN_BACKEND_PUBLIC.BIOMARKER_RESULT ALTER COLUMN TEST_RESULT_OUT_OF_RANGE SET TAG governance_db.sch.HEALTH__INTERNAL = 'manual';
