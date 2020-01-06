#----------------------- ENVIROMENT
locals {
  environment_variables = [
    {
      name  : "DEPLOY_ENV"
      value : var.environment
    },
    {
      name  : "JAVA_AGENT_HOME"
      value : "/opt/appd"
    },
    {
      name  : "SPRING_PROFILES_ACTIVE"
      value : var.environment
    },
    {
      name  : "HOSTNAME_COMMAND"
      value : "curl http://169.254.169.254/latest/meta-data/local-hostname"
    },
    {
      name  : "KAFKA_ADVERTISED_LISTENERS"
      value : "OUTSIDE://_{HOSTNAME_COMMAND}:9092"
    },
    {
      name  : "KAFKA_INTER_BROKER_LISTENER_NAME"
      value : "OUTSIDE"
    },
    {
      name  : "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
      value : "OUTSIDE:PLAINTEXT"
    },
    {
      name  : "KAFKA_LISTENERS"
      value : "OUTSIDE://0.0.0.0:9092"
    },
    {
      name  : "KAFKA_ZOOKEEPER_CONNECT"
      value : "zookeeper:2181"
    },
    {
      name  : "ELASTICSEARCH_HOSTS"
      value : "apm-dev-elasticsearch-alb-937976815.eu-west-1.elb.amazonaws.com"
    },
  ]

//  environment_variables_count = "10"
}