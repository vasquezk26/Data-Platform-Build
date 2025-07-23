SELECT
    p.id AS patient_id
    , p.fname
    , p.lname
    , p.biological_sex
    , p.created_at AS date_joined
    , v.id AS visit_id
    , v.visit_date
    , v.requisition_id
    , MIN(pn.created_at) AS clinician_notes
    , MIN(vm.created_at) AS date_scheduled
    , MIN(br.created_at) AS first_results
    , ARRAY_AGG(DISTINCT pkg.name) AS packages
FROM {{ ref('patient') }} AS p
LEFT JOIN {{ ref('visit') }} AS v ON p.id = v.patient_id
LEFT JOIN {{ ref('visit_package') }} AS vp ON v.id = vp.visit_id
LEFT JOIN {{ ref('package') }} AS pkg ON vp.package_id = pkg.id
LEFT JOIN {{ ref('visit_meta_data') }} AS vm ON v.id = vm.visit_id
LEFT JOIN
    {{ ref('physician_note') }} AS pn
    ON v.requisition_id = pn.requisition_id
LEFT JOIN {{ ref('biomarker_result') }} AS br ON v.id = br.visit_id
GROUP BY ALL
