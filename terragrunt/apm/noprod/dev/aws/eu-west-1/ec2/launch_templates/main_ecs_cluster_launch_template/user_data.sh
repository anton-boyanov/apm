#!/bin/bash
export ECS_CLUSTER=${user_data_cluster_name}
export HOSTNAME=$ECS_CLUSTER-`curl http://169.254.169.254/latest/meta-data/instance-id`

echo $HOSTNAME > /etc/hostname
hostname $HOSTNAME

/usr/local/bin/aws ecs put-account-setting         --name awsvpcTrunking --value enabled
/usr/local/bin/aws ecs put-account-setting-default --name awsvpcTrunking --value enabled

mkdir -p /etc/ecs
echo ECS_AVAILABLE_LOGGING_DRIVERS='["awslogs","fluentd"]' >> /etc/ecs/ecs.config
echo ECS_CLUSTER=$ECS_CLUSTER >> /etc/ecs/ecs.config

