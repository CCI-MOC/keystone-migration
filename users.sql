\! echo migrate user
insert into keystone.user
	(id, extra, enabled, default_project_id, created_at, last_active_at, domain_id)
	select id, extra, enabled, default_project_id, created_at, last_active_at, domain_id
	from _users
	where other_user_name is null
	;

\! echo migrate local_user
insert into keystone.local_user (user_id, domain_id, name)
	select id, domain_id, local_user_name
	from _users
	where
	other_user_name is null
	;

