BEGIN;

-- migrate projects
--
-- This copies over all projects other than the 'services' and 'admin' project.
\! echo migrate project
insert into keystone.project
	select *
	from project
	where
	name not in ('services', 'admin')
	and domain_id = 'default';

-- migrate users
--
-- Copy over data from the user table for users who have role "_member_" on a
-- project.  Explicitly exclude user names that would conflict with a user name
-- in the target database.
\! echo migrate user
insert into keystone.user
	(id, extra, enabled, default_project_id, created_at, last_active_at, domain_id)
	select distinct(user.id), user.extra, user.enabled, user.default_project_id,
	user.created_at, user.last_active_at, user.domain_id
	from user
	join local_user on user.id = local_user.user_id
	join assignment on user.id = assignment.actor_id
	join role on role.id = assignment.role_id
	where
	assignment.type = 'UserProject' and
	user.domain_id = 'default' and
	role.name = '_member_' and
	local_user.name not in (select name from keystone.local_user)
	;

-- migrate local_users
--
-- Copy over data from the local_users table using identical logic to the 
-- previous statement.
\! echo migrate local_user
insert into keystone.local_user (user_id, domain_id, name)
	select distinct(local_user.user_id), local_user.domain_id, local_user.name
	from user
	join local_user on user.id = local_user.user_id
	join assignment on user.id = assignment.actor_id
	join role on role.id = assignment.role_id
	where
	assignment.type = 'UserProject' and
	user.domain_id = 'default' and
	role.name = '_member_' and
	local_user.name not in (select name from keystone.local_user)
	;

-- migrate passwords
--
-- Copy over passwords for any matching user ids in the target database.

\! echo migrate passwords
insert into keystone.password (
		local_user_id, password, expires_at, self_service,
		created_at, password_hash, created_at_int, expires_at_int
	)
	select c.id, a.password, a.expires_at, a.self_service,
	a.created_at, a.password_hash, a.created_at_int, a.expires_at_int
	from password as a
	join local_user as b on b.id = a.local_user_id
	join keystone.local_user as c on c.user_id = b.user_id
	;

-- migrate project membership
\! echo migrate project membership
set @member_role_id = (select id from keystone.role where name = '_member_');
insert into keystone.assignment (type, actor_id, target_id, role_id, inherited)
	select type, actor_id, target_id, @member_role_id, inherited
	from assignment
	join role on assignment.role_id = role.id
	join project on project.id = assignment.target_id
	where
	assignment.type = 'UserProject' and
	role.name = '_member_' and
	project.name not in ('services', 'admin')
	;

COMMIT;
