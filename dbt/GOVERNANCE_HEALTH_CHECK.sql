-- ============================================================================
-- DATA GOVERNANCE HEALTH CHECK
-- ============================================================================
-- This query validates that the governance system is working correctly
-- Run this as an admin to verify all components are functioning
-- ============================================================================

-- 1. Check if governance schema exists
SELECT 'GOVERNANCE SCHEMA CHECK' as check_type,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status,
       CASE WHEN COUNT(*) > 0 
            THEN 'Governance schema exists' 
            ELSE 'ERROR: Governance schema missing' END as details
FROM information_schema.schemata 
WHERE schema_name = 'governance'

UNION ALL

-- 2. Check if catalog-level masking function exists  
SELECT 'CATALOG MASKING FUNCTION' as check_type,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status,
       CASE WHEN COUNT(*) > 0 
            THEN 'Catalog masking function exists' 
            ELSE 'ERROR: mask_restricted_default function missing' END as details
FROM information_schema.functions 
WHERE function_schema = 'governance' 
AND function_name = 'mask_restricted_default'

UNION ALL

-- 3. Check if schema-level masking functions exist
SELECT 'SCHEMA MASKING FUNCTIONS' as check_type,
       CASE WHEN COUNT(*) >= 3 THEN '✅ PASS' 
            WHEN COUNT(*) > 0 THEN '⚠️ PARTIAL' 
            ELSE '❌ FAIL' END as status,
       CONCAT(COUNT(*), ' schema masking functions found (expecting multiple)') as details
FROM information_schema.functions 
WHERE function_name = 'mask_restricted'
AND function_schema LIKE 'db_%'

UNION ALL

-- 4. Check if catalog-level policy exists
SELECT 'CATALOG POLICY CHECK' as check_type,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status,
       CASE WHEN COUNT(*) > 0 
            THEN 'Catalog-level policy active' 
            ELSE 'ERROR: Catalog default-deny policy missing' END as details
FROM information_schema.column_masks
WHERE policy_name = 'catalog_default_deny'

UNION ALL

-- 5. Check if schema-level policies exist  
SELECT 'SCHEMA POLICIES CHECK' as check_type,
       CASE WHEN COUNT(*) >= 9 THEN '✅ PASS'
            WHEN COUNT(*) > 0 THEN '⚠️ PARTIAL' 
            ELSE '❌ FAIL' END as status,
       CONCAT(COUNT(*), ' schema policies found (expecting 3 per governed schema)') as details
FROM information_schema.column_masks
WHERE policy_name IN ('admin_full_access', 'health_reader_limited_access', 'default_user_access')

UNION ALL

-- 6. Check if governed tables have column tags
SELECT 'COLUMN TAGS CHECK' as check_type,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status,
       CONCAT(COUNT(*), ' tagged columns found') as details
FROM information_schema.column_tags 
WHERE tag_name IN ('class', 'sensitivity')
AND schema_name LIKE 'db_%'

UNION ALL

-- 7. Check if PII protection is active (test query)
SELECT 'PII PROTECTION TEST' as check_type,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '⚠️ NO PII COLUMNS' END as status,
       CONCAT(COUNT(*), ' PII columns properly tagged') as details
FROM information_schema.column_tags 
WHERE tag_name = 'class' AND tag_value = 'pii'

UNION ALL

-- 8. Environment configuration check
SELECT 'ENVIRONMENT CONFIG' as check_type,
       '✅ PASS' as status,
       CONCAT('Environment: ', 
              CASE WHEN current_catalog() LIKE '%dev%' THEN 'DEV' 
                   WHEN current_catalog() LIKE '%prod%' THEN 'PROD' 
                   ELSE 'UNKNOWN' END) as details

ORDER BY check_type;

-- ============================================================================
-- DETAILED GOVERNANCE INVENTORY
-- ============================================================================

-- Show all governed schemas and their policy counts
SELECT 'GOVERNANCE INVENTORY' as section,
       '===================' as divider,
       '' as details
       
UNION ALL

SELECT '' as section,
       CONCAT('📁 Schema: ', schema_name) as divider,
       CONCAT('   Policies: ', COUNT(DISTINCT policy_name),
              ' | Tagged Columns: ', 
              (SELECT COUNT(*) FROM information_schema.column_tags ct 
               WHERE ct.schema_name = cm.schema_name 
               AND tag_name IN ('class', 'sensitivity'))) as details
FROM information_schema.column_masks cm
WHERE schema_name LIKE 'db_%'
GROUP BY schema_name

UNION ALL

SELECT '' as section, '===================' as divider, '' as details

UNION ALL

-- Show sample of tagged columns for verification
SELECT '' as section,
       '📋 SAMPLE TAGGED COLUMNS:' as divider,
       '' as details
       
UNION ALL

SELECT '' as section,
       CONCAT('   ', schema_name, '.', table_name, '.', column_name) as divider,
       CONCAT('      ', tag_name, '=', tag_value) as details
FROM information_schema.column_tags 
WHERE tag_name IN ('class', 'sensitivity')
AND schema_name LIKE 'db_%'
ORDER BY schema_name, table_name, column_name, tag_name
LIMIT 20;

-- ============================================================================
-- QUICK ACCESS TEST
-- ============================================================================
-- Uncomment the section below to test actual data masking
-- (Replace 'your_test_table' with an actual governed table)

/*
SELECT '🧪 MASKING TEST' as section,
       '================' as divider,
       '' as details

UNION ALL

SELECT 'Testing data masking on actual table...' as section,
       'Table: db_admin_backend.disease' as divider, 
       '' as details;

-- Test query (uncomment to run)
-- SELECT 'Visible columns should show data, PII should show REDACTED' as note;
-- SELECT * FROM db_admin_backend.disease LIMIT 3;
*/