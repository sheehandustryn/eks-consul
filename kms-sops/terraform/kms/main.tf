resource "aws_kms_key" "this" {
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  customer_master_key_spec           = var.customer_master_key_spec
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  enable_key_rotation                = var.enable_key_rotation
  is_enabled                         = var.is_enabled
  key_usage                          = var.key_usage
}

resource "aws_kms_alias" "this" {
  name          = var.alias
  target_key_id = aws_kms_key.this.key_id
}
