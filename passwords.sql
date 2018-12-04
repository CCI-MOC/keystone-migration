\! echo migrate passwords
insert into keystone.password (local_user_id, password, expires_at, self_service, created_at, password_hash, created_at_int, expires_at_int)
select _users.other_user_id,
       password.password,
       password.expires_at,
       password.self_service,
       password.created_at,
       password.password_hash,
       password.created_at_int,
       password.expires_at_int
from password
join _users using (local_user_id)
left join keystone.password as other on other.local_user_id = _users.other_user_id
where other.local_user_id is null
