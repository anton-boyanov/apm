#---iam/main.tf

#------------------------------------------- ecs_instance_role
data "template_file" "ecs_instance_role" {
    template= file("iam/ecs_instance_role.tpl")
}
data "template_file" "ecs_instance_role_policy" {
    template= file("iam/ecs_instance_role_policy.tpl")
}

resource "aws_iam_role" "ecs_instance_role" {
    //    name = "ecs_instance_role_${var.environment}"
    name = "terraform-20190926194703502900000002"
    assume_role_policy = data.template_file.ecs_instance_role.rendered
}
resource "aws_iam_role_policy" "ecs_instance_role_policy" {
    name = "ecs_instance_role_policy_${var.environment}"
    role = aws_iam_role.ecs_instance_role.id
    policy = data.template_file.ecs_instance_role_policy.rendered
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
    name = "ecs_instance_profile_${var.environment}"
    role = aws_iam_role.ecs_instance_role.name
}

#------------------------------------------- ecs_service_role
data "template_file" "ecs_service_role" {
    template= file("iam/ecs_service_role.tpl")
}
data "template_file" "ecs_service_role_policy" {
    template= file("iam/ecs_service_role_policy.tpl")
}
resource "aws_iam_role" "ecs_service_role" {
//    name = "ecs_service_role_${var.environment}"
    name = "terraform-20190926194703502800000001"
    assume_role_policy = data.template_file.ecs_service_role.rendered
}
resource "aws_iam_role_policy" "ecs_service_role_policy" {
    name = "ecs_service_role_${var.environment}"
    role = aws_iam_role.ecs_service_role.id
    policy = data.template_file.ecs_service_role_policy.rendered
}

