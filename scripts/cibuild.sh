#!/bin/bash

# Exit code starts at 0 but is modified if any checks fail
EXIT=0

# Output a line prefixed with a timestamp
info()
{
	echo "$(date +'%F %T') |"
}

# Track number of seconds required to run script
START=$(date +%s)
echo "$(info) starting build checks."

# Syntax check all python source files
SYNTAX=$(find . -name "*.py" -type f -exec python -m py_compile {} \; 2>&1)
if [[ ! -z $SYNTAX ]]; then
	echo -e "$SYNTAX"
	echo -e "\n$(info) detected one or more syntax errors, failing build."
	EXIT=1
fi

# Prepare configuration file for use in CI
CONFIG="netbox/netbox/configuration.py"
cp netbox/netbox/configuration.example.py $CONFIG
sed -i -e "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['*'\]/g" $CONFIG
sed -i -e "s/SECRET_KEY = ''/SECRET_KEY = 'netboxci'/g" $CONFIG

# Run NetBox tests
./netbox/manage.py test

# Show build duration
END=$(date +%s)
echo "$(info) exiting with code $EXIT after $(($END - $START)) seconds."

exit $EXIT
