SELECT
        p.id AS patient_id,
        p.first_name,
        p.last_name,
        p.biological_sex,
        p.created_at AS date_joined,
        v.id AS visit_id,
        v.visit_date,
        v.requisition_id,
        min(pn.created_at) AS clinician_notes,
        min(vm.created_at) AS date_scheduled,
		    min(br.created_at) as first_results,
        ARRAY_AGG(DISTINCT pkg.name) AS packages
    FROM
        {{ ref('patient') }} p
    LEFT JOIN
        {{ ref('visit') }} v ON p.id = v.patient_id
    LEFT JOIN
        {{ ref('visit_package') }} vp ON v.id = vp.visit_id
    LEFT JOIN
        {{ ref('package') }} pkg ON vp.package_id = pkg.id
    LEFT JOIN
		{{ ref('visit_meta_data') }} vm ON v.id = vm.visit_id
    LEFT JOIN
        {{ ref('physician_note') }} pn ON v.requisition_id = pn.requisition_id
    LEFT JOIN
		{{ ref('biomarker_result') }} br ON v.id = br.visit_id
    GROUP BY
        p.id, p.biological_sex, p.created_at, vm.created_at, v.id, v.visit_date, v.requisition_id
