# IAM Role
resource "aws_iam_role" "this" {
  name               = "${var.name_prefix}-role"
  assume_role_policy = var.assume_role_policy

  tags = var.tags
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Attach inline policies
resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value.policy
}