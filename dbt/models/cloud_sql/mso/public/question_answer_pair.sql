
SELECT
  _fivetran_active
  -- , answer
  -- , answer_kind
  -- , external_id
  -- , extra
  -- , id
  -- , is_appropriate_for_leads
  -- , priority
  -- , question
  -- , question_embedding
  -- , question_tsv
  -- , topic
FROM
  {{ source('mso', 'question_answer_pair') }}
WHERE
  _fivetran_active = True
