output "aws_kms_key_arn" {
  value = aws_kms_key.this.arn
}

output "aws_kms_key_id" {
  value = aws_kms_key.this.id
}

output "aws_kms_key_tags" {
  value = aws_kms_key.this.tags_all
}

output "aws_kms_alias_arn" {
  value = aws_kms_alias.this.arn
}
