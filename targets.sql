-- Create a list of users to migrate using the following criteria:
--
-- * Not a member of the 'services' or 'admin' project
-- * Belongs to the 'default' domain
create or replace view _users as
select distinct(user.id),
       user.extra,
       user.enabled,
       user.default_project_id,
       user.created_at,
       user.last_active_at,
       user.domain_id,
       local_user.name as local_user_name,
       local_user.id as local_user_id,
       other_user.name as other_user_name,
       other_user.id as other_user_id
from user
join local_user on user.id = local_user.user_id
left join keystone.local_user as other_user on other_user.name = local_user.name
join assignment on user.id = assignment.actor_id
join role on role.id = assignment.role_id
join project on project.id = assignment.target_id
where assignment.type = 'UserProject'
  and user.domain_id = 'default'
  and role.name = '_member_'
  and project.name not in ('services', 'admin')
;

create or replace view _projects as
select project.id,
       project.name as local_project_name,
       other_project.name as other_project_name,
       project.extra,
       project.description,
       project.enabled,
       project.domain_id,
       project.parent_id,
       project.is_domain
from project
left join keystone.project as other_project on project.name = other_project.name
where project.name not in ('services', 'admin')
  and project.domain_id = 'default';
