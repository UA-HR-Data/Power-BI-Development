-- Employees.xlsx --

  select distinct iden.spriden_pidm pidm,
         iden.spriden_id uaid,
         iden.spriden_last_name last_name,
         iden.spriden_first_name first_name,
         substr(iden.spriden_mi, 1, 1) mi,
         pers.spbpers_gndr_code gender,
         pers.spbpers_sex sex,
         pers.spbpers_birth_date birth_date,
         pers.spbpers_citz_ind citz_ind,
         case
           when pers.spbpers_ethn_cde = 2 then 'Y'
           when pers.spbpers_ethn_cde = 1 then 'N'
           else 'Not Disclosed'
         end as hispanic,
         empl.pebempl_empl_status empl_status,
         empl.pebempl_orgn_code_home empl_orgn,
         empl.pebempl_orgn_code_dist empl_tkl,
         empl.pebempl_ecls_code ecls_code,
         empl.pebempl_lcat_code lcat_code,
         empl.pebempl_bcat_code bcat_code,
         empl.pebempl_first_hire_date first_hire_date,
         empl.pebempl_current_hire_date current_hire_date,
         empl.pebempl_adj_service_date adj_service_date,
         empl.pebempl_seniority_date seniority_date,
         empl.pebempl_wkpr_code wkpr_code,
         empl.pebempl_flsa_ind flsa_ind,
         empl.pebempl_internal_ft_pt_ind ft_pt_ind
    from pebempl empl
    join nbrbjob job on empl.pebempl_pidm = job.nbrbjob_pidm
                    and sysdate between job.nbrbjob_begin_date and nvl(job.nbrbjob_end_date, sysdate)
    join nbrjobs pos on job.nbrbjob_pidm = pos.nbrjobs_pidm
                    and job.nbrbjob_posn = pos.nbrjobs_posn
                    and job.nbrbjob_suff = pos.nbrjobs_suff
                    and pos.nbrjobs_status != 'T'
                    and pos.nbrjobs_effective_date = (select max(pos2.nbrjobs_effective_date)                                              
                                                        from nbrjobs pos2
                                                       where pos.nbrjobs_pidm = pos2.nbrjobs_pidm
                                                         and pos.nbrjobs_posn = pos2.nbrjobs_posn
                                                         and pos.nbrjobs_suff = pos2.nbrjobs_suff
                                                         and pos2.nbrjobs_effective_date <= sysdate)
    join spriden iden on empl.pebempl_pidm = iden.spriden_pidm
                     and iden.spriden_change_ind is null
    join spbpers pers on empl.pebempl_pidm = pers.spbpers_pidm
   where empl.pebempl_empl_status = 'A';



-- Jobs.xlsx -- 

  select iden.spriden_pidm pidm,
         iden.spriden_id uaid,
         job.nbrbjob_contract_type contract_type,
         job.nbrbjob_posn job_posn,
         job.nbrbjob_suff job_suff,
         job.nbrbjob_begin_date job_begin_date,
         job.nbrbjob_end_date job_end_date,
         pos.nbrjobs_effective_date effective_date,
         pos.nbrjobs_pers_chg_date pers_chg_date,
         pos.nbrjobs_status job_status,
         pos.nbrjobs_desc job_title,
         pos.nbrjobs_ecls_code job_ecls_code,
         pos.nbrjobs_orgn_code_ts job_tkl,
         pos.nbrjobs_sal_table sal_table,
         pos.nbrjobs_sal_grade sal_grade,
         pos.nbrjobs_sal_step sal_step,
         pos.nbrjobs_fte adjunct_semesters,
         pos.nbrjobs_hrs_day hrs_day,
         pos.nbrjobs_hrs_pay hrs_pay,
         pos.nbrjobs_reg_rate reg_rate,
         pos.nbrjobs_assgn_salary assgn_salary,
         pos.nbrjobs_factor factor,
         pos.nbrjobs_ann_salary ann_salary,
         pos.nbrjobs_per_pay_salary per_pay_salary,
         pos.nbrjobs_pays pays,
         pos.nbrjobs_jcre_code jcre_code,
         pos.nbrjobs_sgrp_code sgrp_code,
         pos.nbrjobs_supervisor_pidm supervisor_pidm,
         pos.nbrjobs_supervisor_posn supervisor_posn,
         pos.nbrjobs_supervisor_suff supervisor_suff
    from pebempl empl
    join nbrbjob job on empl.pebempl_pidm = job.nbrbjob_pidm
                    and sysdate between job.nbrbjob_begin_date 
                                    and nvl(job.nbrbjob_end_date, sysdate)
    join nbrjobs pos on job.nbrbjob_pidm = pos.nbrjobs_pidm
                    and job.nbrbjob_posn = pos.nbrjobs_posn
                    and job.nbrbjob_suff = pos.nbrjobs_suff
                    and pos.nbrjobs_status != 'T'
                    and pos.nbrjobs_effective_date = (select max(pos2.nbrjobs_effective_date)                                              
                                                        from nbrjobs pos2
                                                       where pos.nbrjobs_pidm = pos2.nbrjobs_pidm
                                                         and pos.nbrjobs_posn = pos2.nbrjobs_posn
                                                         and pos.nbrjobs_suff = pos2.nbrjobs_suff
                                                         and pos2.nbrjobs_effective_date <= sysdate)
    join spriden iden on empl.pebempl_pidm = iden.spriden_pidm
                     and iden.spriden_change_ind is null
    join spbpers pers on empl.pebempl_pidm = pers.spbpers_pidm
   where empl.pebempl_empl_status = 'A';
    
    
-- Race Information.xlsx --

desc gorprac;

  select gorprac_pidm pidm,
         gorprac_race_cde race_cde,
         ethn.stvethn_desc race_desc,
         etct.stvetct_desc group_desc,
         case
           when count(distinct etct.stvetct_desc) over (partition by prac.gorprac_pidm) > 1 then 'Two or more races'
           else etct.stvetct_desc
         end fed_group_desc,
         count(distinct etct.stvetct_desc) over (partition by prac.gorprac_pidm) multi
    from gorprac prac
    join stvethn ethn on prac.gorprac_race_cde = ethn.stvethn_code
    join stvetct etct on ethn.stvethn_etct_code = etct.stvetct_code
    join pebempl empl on prac.gorprac_pidm = empl.pebempl_pidm
                     and empl.pebempl_empl_status = 'A'
order by pidm desc;