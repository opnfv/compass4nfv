set -x
function get_option_name_list()
{
    echo $(echo "$1" | xargs -n 1 grep -oP "export .*?=" | \
            awk '{print $2}' | sort | uniq | sed -e 's/=$//g')
}
function get_option_flag_list()
{
    echo $(echo "$1" | tr [:upper:] [:lower:] | \
                 xargs | sed  -e 's/ /:,/g' -e 's/_/-/g')
}

function get_conf_name()
{
    cfg_file=`ls $COMPASS_DIR/deploy/conf/*.conf`
    option_name=`get_option_name_list "$cfg_file"`
    option_flag=`get_option_flag_list "$option_name"`

    TEMP=`getopt -o h -l $option_flag -n 'deploy_parameter.sh' -- "$@"`

    if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
    eval set -- "$TEMP"
    while :; do
        if [[ "$1" == "--" ]]; then
            shift
            break
        fi
        shift
    done

    if [[ $# -eq 0 ]]; then
        echo "virtual_cluster"
    elif [[ "$1" == "five" ]];then
        echo "virtual_five"
    else
        echo $1
    fi
}

function generate_input_env_file()
{
    ofile="$WORK_DIR/script/deploy_input.sh"

    echo  '#input deployment  parameter' > $ofile

    cfg_file=`ls $COMPASS_DIR/deploy/conf/{base,"$TYPE"_"$FLAVOR",$TYPE,$FLAVOR}.conf 2>/dev/null`
    option_name=`get_option_name_list "$cfg_file"`
    option_flag=`get_option_flag_list "$option_name"`

    TEMP=`getopt -o h -l conf-name:,$option_flag -n 'deploy_parameter.sh' -- "$@"`

    if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
    eval set -- "$TEMP"
    while :; do
        if [[ "$1" == "--" ]]; then
            shift
            break
        fi

        option=`echo ${1##-?} | tr [:lower:] [:upper:] | sed 's/-/_/g'`
        echo "$option_name" | grep -w $option > /dev/null
        if [[ $? -eq 0 ]]; then
            echo "export $option=$2" >> $ofile
            shift 2
            continue
        fi

        echo "Internal error!"
        exit 1
    done

    echo $ofile
}

function process_default_para()
{
    python ${COMPASS_DIR}/deploy/config_parse.py \
           "${COMPASS_DIR}/deploy/conf/`get_conf_name $*`" \
           "${COMPASS_DIR}/deploy/template" \
           "${WORK_DIR}/script" \
           "deploy_config.sh"

    echo ${WORK_DIR}/script/deploy_config.sh
}

function process_input_para()
{
    input_file=`generate_input_env_file $config_file $*`

    echo $input_file
}
