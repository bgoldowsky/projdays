DIRS := app db lib public
DEST := /var/www/html/projdays/

test-update:
	rsync -n -Cav $(DIRS) $(DEST)

update:
	rsync -Cav $(DIRS) $(DEST)
	touch $(DEST)tmp/restart.txt
