\! echo migrate project
insert into keystone.project
select id,
       local_project_name,
       extra,
       description,
       enabled,
       domain_id,
       parent_id,
       is_domain
from _projects
where other_project_name is null;

