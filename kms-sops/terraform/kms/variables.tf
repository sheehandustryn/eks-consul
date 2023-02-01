variable "alias" {
  type        = string
  description = "(Optional) The display name of the alias. The name must start with the word alias followed by a forward slash (alias/)"
}

variable "bypass_policy_lockout_safety_check" {
  type        = bool
  description = "(Optional) Specifies whether to disable the policy lockout check performed when creating or updating the key's policy. Setting this value to true increases the risk that the CMK becomes unmanageable."
  default     = false
}

variable "customer_master_key_spec" {
  type        = string
  description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1"
  default     = "SYMMETRIC_DEFAULT"
}

variable "deletion_window_in_days" {
  type        = number
  description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
  default     = 7
}

variable "description" {
  type        = string
  description = "(Optional) The description of the key as viewed in AWS console."
  default     = ""
}

variable "enable_key_rotation" {
  type        = bool
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = false
}

variable "is_enabled" {
  type        = bool
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
}

variable "key_usage" {
  type        = string
  description = " (Optional) Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT or SIGN_VERIFY."
  default     = "ENCRYPT_DECRYPT"
}