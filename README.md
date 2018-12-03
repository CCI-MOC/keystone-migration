Migrate users from one keystone installation to another, without
overwriting admin/service users in the target environment.

Usage:

    mysql keystone_old < migrate.sql

Where *keystone_old* is the name of the database **from** which you
are migrating.  The migration script will insert data into a database
named `keystone`.
