# this has been set for hadoop historically but not sure it is needed anymore
export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true
export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-"/etc/hadoop"}