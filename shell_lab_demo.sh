#!/bin/bash
. /home/project/.bash_profile
. /etc/profile



##############################################################
# 1. Set Default Variables

HOST=$HOSTNAME

SHORT_DATE=`date '+%Y-%m-%d'`

TIME=`date '+%H%M'`


##############################################################
# Product Variables

PRODUCT_USERNAME=`whoami`

##############################################################
######### DO NOT MODIFY ABOVE THIS LINE ######################

# Setting up environment variables

filenametime1=$(date +"%m%d%Y%H%M%S")
filenametime2=$(date +"%Y-%m-%d %H:%M:%S")

export BASE_PATH="/home/project/product"
export SCRIPTS_FOLDER="/home/project/product/scripts"
export ENV_ACTIVATION_LOCATION="/home/project/product/venv/bin/activate"

export LOGDIR='/home/project/product/logs'
export DOCDIR='/home/project/product/docs'

export TASK_CLIENT='client'
export TASK_TASK='product category api call'

export SCRIPT='script'
export LOG_FILE=${LOGDIR}/${SCRIPT}_${filenametime1}.log
export PYTHON_LOG_FILE=${LOGDIR}/${SCRIPT}_python_${filenametime1}.log


cd ${SCRIPTS_FOLDER}

# exec 2> ${LOG_FILE} 1>&2
exec > >(tee ${LOG_FILE})
exec 2> >(tee ${LOG_FILE} >&2)

##############################################################
## JOB START
echo "\nSTART"

echo "\n[SYSINFO]: EXECUTING ON SERVER: ${SHOST}\n---------------------------"

echo "[JOB]: ${TASK_CLIENT} ${TASK_TASK} PROCESS START AT $(date)\n---------------------------\n"

source ${ENV_ACTIVATION_LOCATION}

echo "[SNOWFLAKE]: FETCH category_source_table FROM product_control_table"
export CATEGORY_SOURCE_TABLE=$(snowsql -c project -o log_level=DEBUG  -o friendly=false -o header=false -o timing=false -o output_format=tsv -q "select variable_value from project.product_control_table where script_name = 'script' and variable = 'category_source_table' and active=TRUE;")
echo "CATEGORY_SOURCE_TABLE=$CATEGORY_SOURCE_TABLE\n"

echo "[SNOWFLAKE]: FETCH client_category_id FROM product_control_table"
export CLIENT_CATEGORY_ID=$(snowsql -c project -o log_level=DEBUG  -o friendly=false -o header=false -o timing=false -o output_format=tsv -q "select variable_value from project.product_control_table where script_name = 'script' and variable = 'client_category_id' and active=TRUE;")
echo "CLIENT_CATEGORY_ID=$CLIENT_CATEGORY_ID\n"

echo "[SNOWFLAKE]: FETCH client_category_desc FROM product_control_table"
export CLIENT_CATEGORY_DESC=$(snowsql -c project -o log_level=DEBUG  -o friendly=false -o header=false -o timing=false -o outpuret_format=tsv -q "select variable_value from project.product_control_table where script_name = 'script' and variable = 'client_category_desc' and active=TRUE;")
echo "CLIENT_CATEGORY_DESC=$CLIENT_CATEGORY_DESC\n"




##############################################################
# Begin PYTHON SCRIPT

echo "[PROCESS]: STARTING RUN PYTHON SCRIPT '${SCRIPT}.py'.\n"
python3 ${SCRIPTS_FOLDER}/script.py

RC1=$?
if [ ${RC1} != 0 ]; then
	echo "\n[ERROR:] ERROR FOR SCRIPT ${SCRIPT}.py"
	echo "[ERROR:] RETURN CODE:  ${RC1}"
	echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
	echo "[ERROR:] LOG FILE NAME: "${PYTHON_LOG_FILE}
	exit 1
fi

echo "\n[SUCESS]:SCRIPT ${SCRIPT}.py RUNNING SUCCEDED"
echo "[PROCESS]: END SCRIPT RUNNING PROCESS"

##ENDING PROCESS
echo "\n[JOB]: LOAD SESSION OF ${TASK_CLIENT} ${TASK_TASK} PROCESS COMPLETED SUCCESSFULLY."
echo "[JOB]: ${TASK_CLIENT} ${TASK_TASK} PROCESS END AT $(date)"
echo -e "\nEND"

exit 0
