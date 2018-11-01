all:

setup:
	psql -d csi3130_lab1 -a -f drop_dbs.sql
	psql -d csi3130_lab1 -a -f create_db.sql
	psql -d csi3130_lab1 -a -f populate-database.sql

drop:
	psql -d csi3130_lab1 -a -f drop_dbs.sql

entry:
	psql -d csi3130_lab1