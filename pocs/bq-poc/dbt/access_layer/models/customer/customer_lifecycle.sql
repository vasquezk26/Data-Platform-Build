SELECT
        p.id AS patient_id,
        p.biological_sex,
        p.created_at AS date_joined,
        v.id AS visit_id,
        v.visit_date,
        v.requisition_id,
        min(pn.created_at) AS clinician_notes, -- this messes everything up
        min(vm.created_at) AS date_scheduled,
		    min(br.created_at) as first_results,
        ARRAY_AGG(DISTINCT pkg.name IGNORE NULLS) AS packages
    FROM
        admin_app_backendpublic.patient p
    LEFT JOIN
        admin_app_backendpublic.visit v ON p.id = v.patient_id
    LEFT JOIN
        admin_app_backendpublic.visit_package vp ON v.id = vp.visit_id
    LEFT JOIN
        admin_app_backendpublic.package pkg ON vp.package_id = pkg.id
    LEFT JOIN
		admin_app_backendpublic.visit_meta_data vm ON v.id = vm.visit_id
    LEFT JOIN
        admin_app_backendpublic.physician_note pn ON v.requisition_id = pn.requisition_id -- this join exponentially increases the time of the query
    LEFT JOIN
		admin_app_backendpublic.biomarker_result br ON v.id = br.visit_id
    GROUP BY
        p.id, p.biological_sex, p.created_at, vm.created_at, v.id, v.visit_date, v.requisition_id
