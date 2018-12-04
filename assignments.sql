\! echo migrate project membership
insert into keystone.assignment (type, actor_id, target_id, role_id, inherited)
select 'UserProject',
       local.actor_id,
       local.target_id,
       local.role_id,
       local.inherited
from assignment as local
join role on local.role_id = role.id
join _users on local.actor_id = _users.id
join project on local.target_id = project.id
join keystone.role as other_role on role.name = other_role.name
left join keystone.assignment as other on local.actor_id = other.actor_id
and local.target_id = other.target_id
where role.name = '_member_'
  and other_role.name = '_member_'
  and other.actor_id is null


